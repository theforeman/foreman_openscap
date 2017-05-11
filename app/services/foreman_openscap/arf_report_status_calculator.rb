module ForemanOpenscap
  class ArfReportStatusCalculator

    def initialize(options = {})
      @counters   = options[:counters]  || {}
      @raw_status = options[:bit_field] || 0
    end

    def calculate
      @raw_status = 0
      counters.each do |type, value|
        value = value.to_i
        value = ArfReport::MAX if value > ArfReport::MAX
        @raw_status |= value << (ArfReport::BIT_NUM * ArfReport::METRIC.index(type))
      end
      raw_status
    end

    def status
      @status ||= begin
        calculate if raw_status == 0
        counters = Hash.new(0)
        ArfReport::METRIC.each do |m|
          counters[m] = (raw_status || 0) >> (ArfReport::BIT_NUM * ArfReport::METRIC.index(m)) & ArfReport::MAX
        end
        counters
      end
    end

    def status_of(counter)
      raise(Foreman::Exception.new(N_("invalid type %s"), counter)) unless ArfReport::METRIC.include?(counter)
      status[counter]
    end

    ArfReport::METRIC.each do |method|
      define_method method do
        status_of(method)
      end
    end

    private

    attr_accessor :raw_status, :counters
  end
end
