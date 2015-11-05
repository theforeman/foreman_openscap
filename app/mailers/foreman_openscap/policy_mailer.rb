module ForemanOpenscap
  class PolicyMailer  < ::ApplicationMailer

    def policy_summary(options = {})
      set_url
      user = ::User.find(options[:user])
      @time = options[:time] || 1.day.ago

      @policies = ::ForemanOpenscap::Policy.all.reject { |policy| policy.assets.map(&:host).compact.empty? }
      @compliant_hosts = @policies.map { |policy| Host.where(:id => policy.assets.comply_with(policy).map(&:assetable_id)) }.flatten
      @incompliant_hosts = @policies.map { |policy| Host.where(:id => policy.assets.incomply_with(policy).map(&:assetable_id)) }.flatten
      changed_hosts_of_policies(@policies)

      if user.nil? || user.mail.nil?
        logger.warn "User with valid email not supplied, mail report will not be sent"
      else
        set_locale_for(user) do
          subject = _("Scap policies summary")
          mail(:to => user.mail, :subject => subject)
        end
      end
    end

    private

    def changed_hosts_of_policies(policies)
      hash = @policies.inject({}) do |result, policy|
        result[policy.id] = policy.hosts
        result
      end

      @changed_hosts = []
      hash.each do |key, values|
        values.each do |host|
          @changed_hosts << host if host.scap_status_changed?(::ForemanOpenscap::Policy.find key)
        end
      end
      @changed_hosts.uniq
    end

  end
end
