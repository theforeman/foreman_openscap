module ForemanOpenscap
  module BaseTemplateScopeExtensions
    extend ActiveSupport::Concern

    def host_cve_scope(host, input)
      host_cves = host.cves
      input == 'yes' ? host_cves.where(:has_errata => false) : host_cves
    end
  end
end
