module ForemanOpenscap
  module ClientConfig
    class Manual < Base
      def type
        :manual
      end

      def available?
        true
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
