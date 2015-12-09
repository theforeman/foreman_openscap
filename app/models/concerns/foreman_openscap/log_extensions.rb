module ForemanOpenscap
  module LogExtensions
    extend ActiveSupport::Concern
    included do
      attr_accessible :result
    end
  end
end
