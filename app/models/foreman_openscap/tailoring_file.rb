module ForemanOpenscap
  class TailoringFile < ApplicationRecord
    include Authorizable
    include Taxonomix
    include DataStreamContent
    audited :except => [:scap_file]

    has_many :policies
    has_many :scap_content_profiles, :dependent => :destroy
    validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 255 }

    scoped_search :on => :name,              :complete_value => true
    scoped_search :on => :original_filename, :complete_value => true, :rename => :filename

    def fetch_profiles
      api = ProxyAPI::Openscap.new(:url => proxy_url)
      api.fetch_profiles_for_tailoring_file(scap_file)
    end
  end
end
