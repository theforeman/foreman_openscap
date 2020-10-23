module ForemanOpenscap
  module Oval
    class CheckCollection
      attr_reader :checks

      def initialize(initial_check_attrs = [])
        @checks = initial_check_attrs.map { |hash| SetupCheck.new hash }
      end

      def all_passed?
        @checks.all?(&:passed?)
      end

      def find_check(check_id)
        @checks.find { |item| item.id == check_id }
      end

      def find_failed
        @checks.select(&:failed?)
      end

      def fail_check(check_id, error_data = nil)
        find_check(check_id).fail_with! error_data
      end

      def pass_check(check_id)
        find_check(check_id).pass!
      end

      def add_check(check)
        @checks << check
        self
      end

      def merge(other)
        @checks = @checks.concat other.checks
        self
      end

      def to_h
        @checks.map(&:to_h)
      end
    end
  end
end
