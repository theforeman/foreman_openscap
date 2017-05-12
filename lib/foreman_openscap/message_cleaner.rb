module ForemanOpenscap
  class MessageCleaner
    def clean
      ForemanOpenscap::Policy.unscoped.all.find_in_batches do |batch|
        batch.each do |policy|
          process_policy policy
        end
      end
    end

    private

    def process_policy(policy)
      reports_of_policy = ForemanOpenscap::ArfReport.unscoped
                                                    .of_policy(policy)
                                                    .order("#{ForemanOpenscap::ArfReport.table_name}.created_at DESC")
      latest = reports_of_policy.first
      reports_of_policy.each do |report|
        next if report == latest
        report.logs.each do |log|
          latest_log = latest.logs.find_by(:source_id => log.source_id)
          next unless latest_log
          next if log == latest_log
          latest_message = latest_log.message
          msg = log.message
          log.update_attribute('message_id', latest_message.id)
          msg.destroy! if msg.logs.empty?
        end
      end
    end
  end
end
