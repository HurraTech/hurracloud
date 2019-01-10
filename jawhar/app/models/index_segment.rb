require 'erb'

class IndexSegment < ApplicationRecord
  enum current_status: [ :init, :scheduled, :initial_indexing, :indexing, :completed ]

  belongs_to :index
  belongs_to :parent_segment, :class_name => 'IndexSegment', optional: true
  has_many :child_segments, :class_name => 'IndexSegment', :foreign_key => 'parent_segment_id'

  FSCRAWLER_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_template.json.erb'))
  FSCRAWLER_LOG4J_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_log4j.xml.erb'))

  def fscrawler_settings
    name = es_index_name
    url = "#{self.index.full_path}#{self.is_root? ? "" : self.relative_path}".chomp('/')
    excludes = self.index.index_segments.select{|s| 
      s.id != self.id && (self.is_root? || s.relative_path.index(self.relative_path) == 0)
    }.map {|segment|
      exclude_path = self.is_root? ? segment.relative_path :
                                     segment.relative_path.sub(self.relative_path, '')
      "/#{Regexp.quote(exclude_path)}*"
    }
    excludes = excludes.concat(self.index.settings['excludes'] || [])
    ERB.new(FSCRAWLER_TEMPLATE).result(binding)
  end

  def fscrawler_settings_json
    ActiveSupport::JSON.decode(fscrawler_settings)
  end  

  def fscrawler_log4j_config
    log_file = "/usr/share/hurracloud/zahif/logs/segment-#{self.id}.log"
    ERB.new(FSCRAWLER_LOG4J_TEMPLATE).result(binding)
  end

  def es_index_name
    "#{self.index.name}_#{self.relative_path}".gsub(/[\/\-_\. ]/, '_').downcase
  end

  def is_root?
    self.relative_path == "/"
  end

  def has_been_indexed?
    self.last_run != nil
  end

  def progress
    return 100 if (self.actual_count.to_f == 0 or self.current_status == "completed")
    ((self.indexed_count / self.actual_count.to_f) * 100).round(2)
  end

  def indexed_count
    es = Rails.application.config.es_client
    return 0 unless es.indices.exists? index: self.es_index_name
    (es.count index: self.es_index_name)["count"] || 0
  end

  def find_parent
    return if self.is_root?
    puts "Attempting to find parent segment for #{self.normalized_relative_path}"
    longest_common_path = 0
    parent_segment = nil
    self.index.index_segments.each do |potential_parent|
        puts "Is #{potential_parent.normalized_relative_path} my parent?"
        next if potential_parent.id == self.id || potential_parent.normalized_relative_path.size > self.normalized_relative_path.size
        if self.normalized_relative_path.index(potential_parent.normalized_relative_path) == 0 && potential_parent.normalized_relative_path.size > longest_common_path
            puts "Possible"
            longest_common_path = potential_parent.normalized_relative_path.size
            parent_segment = potential_parent
        end
    end
    puts "My parent is #{parent_segment.normalized_relative_path}" unless parent_segment.nil?
    self.parent_segment = parent_segment unless parent_segment.nil?
  end

  def update_counts
    puts "Updating count / size for #{self.relative_path}"
    children_total_count = self.child_segments.map(&:total_count).inject(0, &:+)
    self.actual_count = self.total_count - children_total_count - self.child_segments.length
    if self.actual_count == 0
        self.actual_size = 0
        return
    end

    children_total_size = self.child_segments.map(&:total_size).inject(0, &:+)    
    self.actual_size = self.total_size - children_total_size
  end

  def normalized_relative_path
    "/#{self.is_root? ? "" : self.relative_path}"
  end

  def size_weight
    (self.actual_size.to_f || 0) / (self.index.size || 1)
  end

  def count_weight
    (self.actual_count.to_f || 0) / (self.index.count || 1)
  end

  def average_file_size
    return 0 if self.actual_count == 0
    self.actual_size / self.actual_count.to_f
  end

  def eta_minutes
    return 0 if self.current_status == "completed"
    return -1 if ["scheduled", "init"].include?(self.current_status)
    elapsed = Time.now - self.last_run_started_at
    (((elapsed.to_f / self.progress) * (100-self.progress).to_f) / 60).round(0)
  end

  def average_file_size_weight
    index_avg_file_size = self.index.size.to_f / self.index.count
    self.average_file_size.to_f / index_avg_file_size
  end

  def relative_indexing_duration(now)
    finish_time = self.current_status == "completed" ? self.last_run : now
    start_time = ["init", "scheduled"].include?(self.current_status) ?  now : self.last_run_started_at
    (finish_time - start_time) / 60
  end

  def indexing_duration_minutes
    relative_indexing_duration(Time.now).round(0)
  end

  def as_json(options={})
    super(options.merge!(methods: [:indexed_count, :progress, :eta_minutes,
                                   :size_weight, :count_weight, :average_file_size,
                                   :average_file_size_weight, :indexing_duration_minutes]))
  end

  
end
