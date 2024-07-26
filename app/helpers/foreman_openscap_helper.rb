require 'foreman_openscap/version'

module ForemanOpenscapHelper
  def scap_doc_button(section)
    documentation_button('Managing_Security_Compliance', type: 'docs', chapter: section)
  end

  def scap_doc_url(section = '')
    documentation_url('Managing_Security_Compliance', type: 'docs', chapter: section)
  end
end
