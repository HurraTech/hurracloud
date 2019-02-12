module ActsAsSourcable

    extend ActiveSupport::Concern
  
    included do
    end
  
    module ClassMethods
      def acts_as_sourcable
        has_one :source, :as => :sourcable, :autosave => true, :dependent => :destroy
      end

      def create_source(unique_id)
        source = Source.where(unique_id: unique_id).first_or_create{ |source| 
          source.unique_id = unique_id        
        }
        Rails.logger.info("Source for #{unique_id} is Source ID # #{source.id}")
        klass = Object.const_get(name)
        if source.sourcable.nil?
          sourcableObject = klass.new
          source.sourcable = sourcableObject
          sourcableObject.source = source
        else
          sourcableObject = source.sourcable
        end
        sourcableObject
      end
  
    end

    def metadata=(value)
      source.metadata=value
    end

    def metadata
      source.metadata
    end

    def size=(value)
      source.size=value
    end

    def size
      source.size
    end

    def used=(value)
      source.used=value
    end

    def used
      source.used
    end
        
    def status=(value)
      source.status=value
    end

    def status
      source.status
    end
        
    def name=(value)
      source.name=value
    end

    def name
      source.name
    end

    def free=(value)
      source.free=value
    end

    def free
      source.free
    end

  end
  