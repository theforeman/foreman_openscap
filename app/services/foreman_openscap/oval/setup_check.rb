module ForemanOpenscap
  module Oval
    class SetupCheck
      attr_reader :result, :id

      def initialize(hash)
        @id = hash[:id]
        @title = hash[:title]
        @fail_msg = hash[:fail_msg]
        @errors = hash[:errors]
        @result = :skip
      end

      def fail_with!(fail_data)
        @fail_msg_data = fail_data
        fail!
      end

      def fail!
        @result = :fail
        self
      end

      def pass!
        @result = :pass
        self
      end

      def failed?
        @result == :fail
      end

      def passed?
        @result == :pass
      end

      def skipped?
        @result == :skip
      end

      def fail_msg
        @fail_msg.call @fail_msg_data if @fail_msg
      end

      def to_h
        {
          :title => @title,
          :result => @result,
          :fail_message => failed? ? fail_msg : nil,
          :errors => @errors
        }
      end
    end
  end
end
