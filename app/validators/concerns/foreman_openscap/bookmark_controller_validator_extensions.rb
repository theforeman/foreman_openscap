module ForemanOpenscap
  module BookmarkControllerValidatorExtensions
    module ClassMethods
      def valid_controllers_list
        controllers = super
        controllers + controllers
                        .select { |controller| controller.start_with?('foreman_openscap_', 'foreman_openscap/') }
                        .map { |controller| controller.sub(%r{^foreman_openscap[/_]}, '') }
      end
    end

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end
  end
end
