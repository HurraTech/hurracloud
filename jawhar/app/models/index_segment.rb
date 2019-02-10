require 'erb'

class IndexSegment < ApplicationRecord
  enum current_status: [ :scheduled, :init, :indexing, :completed, :killed, :cancelled ]

  belongs_to :index
  belongs_to :parent_segment, :class_name => 'IndexSegment', optional: true
  has_many :child_segments, :class_name => 'IndexSegment', :foreign_key => 'parent_segment_id'

  FSCRAWLER_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_template.json.erb'))
  FSCRAWLER_LOG4J_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_log4j.xml.erb'))

  def fscrawler_settings
    name = self.crawler_job_name
    index_name = self.index.es_index_name
    url = "#{self.index.full_path}#{self.is_root? ? "" : self.relative_path}".chomp('/')
    if url.ends_with?(".*")
      includes = [url[url.rindex("/")..-1]]
      url = url[0..url.rindex("/")-1]
    end
    excludes = self.index.index_segments.select{|s| 
      s.id != self.id && (self.is_root? || s.relative_path.index(self.path_without_wildcard) == 0)
    }.map {|segment|
      exclude_path = self.is_root? ? segment.relative_path :
                                     segment.relative_path.sub(self.path_without_wildcard, '')
      start_slash = exclude_path.starts_with?("/") ? "" : "/"
      "#{start_slash}#{exclude_path}"
    }
    excludes = excludes.concat(self.index.settings['excludes'] || [])
    
    includes = includes || "null"
    ocr = self.index.settings['ocr'] || false
    ERB.new(FSCRAWLER_TEMPLATE).result(binding)
  end

  def fscrawler_settings_json
    ActiveSupport::JSON.decode(fscrawler_settings)
  end  

  def fscrawler_log4j_config
    log_file = "#{Rails.root.join('log', "zahif/#{self.index.name}/segment-#{self.id}.log")}"
    ERB.new(FSCRAWLER_LOG4J_TEMPLATE).result(binding)
  end

  def crawler_job_name
    "#{self.index.name}_#{self.relative_path}".gsub(/[\*\/\-_\. ]/, '_').downcase
  end

  def is_root?
    self.relative_path == "/"
  end

  def find_parent
    return if self.is_root?
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
  end

  def path_without_wildcard
    return self.relative_path[0..self.relative_path.rindex("/")] if self.relative_path.ends_with?(".*")
    self.relative_path
  end

  def normalized_relative_path
    "/#{self.is_root? ? "" : self.relative_path}"
  end

  def as_json(options={})
    super(options.merge!(methods: [:is_root?, :path_without_wildcard]))
  end

end
