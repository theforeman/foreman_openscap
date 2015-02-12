FactoryGirl.define do
  factory :arf_report, :class => Scaptimony::ArfReport do |f|
    f.asset
    f.policy
    f.sequence :digest do |n|
      "#{n}#{n}#{n}aabbcc#{n}3322dd"
    end
    date '1973-01-13'
  end
end