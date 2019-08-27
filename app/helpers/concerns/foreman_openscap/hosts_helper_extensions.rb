module ForemanOpenscap
  module HostsHelperExtensions
    def name_column(record)
      record.nil? ? _('Host is deleted') : super(record)
    end
  end
end
