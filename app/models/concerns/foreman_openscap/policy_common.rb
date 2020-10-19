module ForemanOpenscap
  module PolicyCommon
    extend ActiveSupport::Concern

    def cron_line_split
      cron_line.to_s.split(' ')
    end

    def valid_cron_line
      if period == 'custom'
        errors.add(:cron_line, _("does not consist of 5 parts separated by space")) unless cron_line_split.size == 5
      end
    end

    def valid_weekday
      if period == 'weekly'
        errors.add(:weekday, _("is not a valid value")) unless Date::DAYNAMES.map(&:downcase).include? weekday
      end
    end

    def valid_day_of_month
      if period == 'monthly'
        errors.add(:day_of_month, _("must be between 1 and 31")) if !day_of_month || (day_of_month < 1 || day_of_month > 31)
      end
    end
  end
end
