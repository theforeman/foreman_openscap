module ForemanOpenscap
  class TailoringFile < ApplicationRecord
    audited :except => [:scap_file]
    include Authorizable
    include Taxonomix
    include DataStreamContent

    has_many :policies
    has_many :scap_content_profiles, :dependent => :destroy
    validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 255 }

    scoped_search :on => :name,              :complete_value => true
    scoped_search :on => :original_filename, :complete_value => true, :rename => :filename
    scoped_search :on => :created_at

    def fetch_profiles
      api = ProxyAPI::Openscap.new(:url => proxy_url)
      api.fetch_profiles_for_tailoring_file(scap_file)
    end
  end
end
