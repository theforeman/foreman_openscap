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

  def scap_root_url
    @scap_root_url ||= begin
      version = ForemanOpenscap::VERSION.split('.')[0..-2].join('.')
      "https://theforeman.org/plugins/foreman_openscap/#{version}/index.html"
    end
  end
end
