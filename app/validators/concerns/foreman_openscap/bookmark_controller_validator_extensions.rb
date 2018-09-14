module ForemanOpenscap
  module BookmarkControllerValidatorExtensions
    module ClassMethods
      def valid_controllers_list
        super + ActiveRecord::Base.connection
                                  .tables
                                  .map(&:to_s)
                                  .select { |table| table.start_with? 'foreman_openscap_' }
                                  .map { |table| table.sub('foreman_openscap_', '') }
      end
    end

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end
  end
end
