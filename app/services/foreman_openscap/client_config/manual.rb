module ForemanOpenscap
  module ClientConfig
    class Manual < Base
      def type
        :manual
      end

      def available?
        true
      end

      def inline_help
        {
          :text => "This leaves the setup of the foreman_scap_client solely on the user. The policy still needs to be defined in order to link incoming ARF reports."
        }
      end

      def constants
        OpenStruct.new
      end

      def managed_overrides?
        false
      end
    end
  end
end
