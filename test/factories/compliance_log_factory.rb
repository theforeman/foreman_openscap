FactoryGirl.define do
  factory :compliance_log, :class => :log do
    result "fail"
    report
    level_id 1
    source nil
    after(:build) do |log|
      log.message = FactoryGirl.create(:message)
    end
  end
end
