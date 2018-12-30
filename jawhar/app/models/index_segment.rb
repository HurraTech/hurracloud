require 'erb'

class IndexSegment < ApplicationRecord
  enum current_status: [ :init, :scheduled, :indexing, :completed ]

  belongs_to :index

  FSCRAWLER_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_template.json.erb'))

  def fscrawler_settings
    name = "#{self.index.name}_#{self.relative_path}".gsub(/[\/\-_\. ]/, '_').downcase
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

  def is_root?
    self.relative_path == "/"
  end

  def fscrawler_settings_json
    ActiveSupport::JSON.decode(fscrawler_settings)
  end  

  def as_json(options={})
    super(options.merge!(methods: :fscrawler_settings_json))
  end

end
