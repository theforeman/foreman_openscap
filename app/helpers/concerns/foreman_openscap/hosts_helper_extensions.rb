module ForemanOpenscap
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :multiple_actions, :scap
      alias_method_chain :name_column, :scap
    end

    Colors = {
        :passed  => '#89A54E',
        :failed  => '#AA4643',
        :othered => '#DB843D',
    }

    def multiple_actions_with_scap
      multiple_actions_without_scap + [[_('Assign Compliance Policy'), select_multiple_hosts_scaptimony_policies_path],
                                       [_('Unassign Compliance Policy'), disassociate_multiple_hosts_scaptimony_policies_path]]

    end

    def host_policy_breakdown_chart(report, options = {})
      data = []
      [[:passed, _('Passed')],
       [:failed, _('Failed')],
       [:othered, _('Other')],
      ].each { |i|
        data << {:label => i[1], :data => report[i[0]], :color => Colors[i[0]]}
      }
      flot_pie_chart 'overview', _('Compliance reports breakdown'), data, options
    end

    def host_arf_reports_chart(policy_id)
      passed, failed, othered, = [], [], []
      @host.arf_reports.of_policy(policy_id).each do |report|
        passed  << [report.created_at.to_i*1000, report.passed]
        failed  << [report.created_at.to_i*1000, report.failed]
        othered << [report.created_at.to_i*1000, report.othered]
      end
      [{:label => _("Passed"), :data => passed, :color => Colors[:passed]},
       {:label => _("Failed"), :data => failed, :color => Colors[:failed]},
       {:label => _("Othered"), :data => othered, :color => Colors[:othered]}]
    end

    def name_column_with_scap(record)
      record.nil? ? _('Host is deleted') : name_column_without_scap(record)
    end
  end
end
