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
    excludes = excludes.concat(self.index.index_settings['excludes'] || [])
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
    return 100 if (self.size.to_f == 0 or self.current_status == "completed")
    ((self.indexed_count / self.size.to_f) * 100).round(2)
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
    puts "Updating count for #{self.relative_path}"
    children_total_size = self.child_segments.map(&:total_size).inject(0, &:+)
    self.size = self.total_size - children_total_size - self.child_segments.length
    puts "Children total size is #{children_total_size}, my net size is #{self.size}"
  end

  def normalized_relative_path
    "/#{self.is_root? ? "" : self.relative_path}"
  end

  def as_json(options={})
    super(options.merge!(methods: [:indexed_count, :progress]))
  end

  
end
