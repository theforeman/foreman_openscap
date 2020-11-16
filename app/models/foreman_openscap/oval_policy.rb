module ForemanOpenscap
  class OvalPolicy < ApplicationRecord
    audited
    include Authorizable
    include Taxonomix

    include PolicyCommon

    belongs_to :oval_content

    validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 255 }
    validates :period, :inclusion => { :in => %w[weekly monthly custom], :message => _('is not a valid value') }
    validate :valid_cron_line, :valid_weekday, :valid_day_of_month
  end
end
