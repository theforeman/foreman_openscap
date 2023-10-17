require 'foreman_openscap/version'

module ForemanOpenscapHelper
  def scap_doc_link(section = '', text = _('documentation'))
    link_to(
      text,
      scap_doc_url(section),
      :rel => 'external noopener noreferrer', :target => '_blank'
    )
  end

  def scap_doc_url(section = '')
    return scap_root_url if section.empty?

    documentation_url(section, root_url: scap_root_url)
  end

  def doc_flavor
    ::Foreman::Plugin.installed?('katello') ? 'katello' : 'foreman'
  end

  def scap_root_url
    @scap_root_url ||= begin
      version = SETTINGS[:version]
      version = version.tag == 'develop' ? 'nightly' : version.short
      "https://docs.theforeman.org/#{version}/Managing_Security_Compliance/index-#{doc_flavor}-el.html#"
    end
  end
end
