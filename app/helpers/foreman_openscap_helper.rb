require 'foreman_openscap/version'

module ForemanOpenscapHelper
  def scap_doc_button(section)
    documentation_button(section, root_url: scap_doc_url)
  end

  def scap_doc_url(section = '')
    return scap_root_url if section.empty?

    documentation_url(section, root_url: scap_root_url)
  end

  private

  def doc_flavor
    ForemanOpenscap.with_katello? ? 'katello' : 'foreman-el'
  end

  def scap_root_url
    @scap_root_url ||= begin
      version = SETTINGS[:version]
      version = version.tag == 'develop' ? 'nightly' : version.short
      "https://docs.theforeman.org/#{version}/Managing_Security_Compliance/index-#{doc_flavor}.html#"
    end
  end
end
