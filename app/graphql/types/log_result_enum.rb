module Types
  class LogResultEnum < BaseEnum
    ::ForemanOpenscap::LogExtensions::SCAP_RESULT.each do |item|
      value item, description: item
    end
  end
end
