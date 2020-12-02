module ForemanOpenscap
  module PolicyCommon
    extend ActiveSupport::Concern

    included do
      before_validation :update_period_attrs
    end

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

    def update_period_attrs
      case period
      when 'monthly'
        erase_period_attrs(%w[cron_line weekday])
      when 'weekly'
        erase_period_attrs(%w[cron_line day_of_month])
      when 'custom'
        erase_period_attrs(%w[weekday day_of_month])
      end
    end

    private

    def erase_period_attrs(attrs)
      attrs.each { |attr| self.public_send("#{attr}=", nil) }
    end

    def period_enc
      # get crontab expression as an array (minute hour day_of_month month day_of_week)
      cron_parts = case period
                   when 'weekly'
                     ['0', '1', '*', '*', weekday_number.to_s]
                   when 'monthly'
                     ['0', '1', day_of_month.to_s, '*', '*']
                   when 'custom'
                     cron_line_split
                   else
                     raise 'invalid period specification'
                   end

      {
        'minute' => cron_parts[0],
        'hour' => cron_parts[1],
        'monthday' => cron_parts[2],
        'month' => cron_parts[3],
        'weekday' => cron_parts[4],
      }
    end

    def weekday_number
      # 0 is sunday, 1 is monday in cron, while DAYS_INTO_WEEK has 0 as monday, 6 as sunday
      (Date::DAYS_INTO_WEEK.with_indifferent_access[weekday] + 1) % 7
    end
  end
end
