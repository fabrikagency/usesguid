# from Demetrio Nunes
# Modified by Andy Singleton to use different GUID generator
# Further modified by Brian Morearty to:
# 1. optionally use the MySQL GUID generator
# 2. respect the "column" option
# 3. set the id before create instead of after initialize
#
# MIT License

require 'uuid_mysql'

module ActiveRecord
  module Usesguid #:nodoc:
  
    def self.append_features(base)
      super
      base.extend(ClassMethods)  
    end

    
    module ClassMethods
      
      # guid_generator: :mysql
      def guid_generator=(generator); class_eval { @guid_generator = generator } end
      def guid_generator; class_eval { @guid_generator || :mysql } end

      def usesguid(options = {})
                
        class_eval do
          set_primary_key options[:column] if options[:column]
          
          before_create :assign_guid

          # Give this record a guid id.  Public method so people can call it before save if necessary.
          def assign_guid
            self[self.class.primary_key] ||= case ActiveRecord::Base.guid_generator
            when :mysql then UUID.mysql_create(self.connection)
            else raise "Unrecognized guid generator '#{ActiveRecord::Base.guid_generator.to_s}'"
            end
          end

        end

      end

    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::Usesguid
end