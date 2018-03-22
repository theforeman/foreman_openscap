module ForemanOpenscap
  class ScapContent < ApplicationRecord
    audited :except => [:scap_file]
    include Authorizable
    include Taxonomix
    include DataStreamContent

    has_many :scap_content_profiles, :dependent => :destroy
    has_many :policies

    validates :title, :presence => true, :length => { :maximum => 255 }, uniqueness: true
    validates :original_filename, :length => { :maximum => 255 }

    scoped_search :on => :title,             :complete_value => true
    scoped_search :on => :original_filename, :complete_value => true, :rename => :filename

    default_scope do
      with_taxonomy_scope do
        order("foreman_openscap_scap_contents.title")
      end
    end

    def used_location_ids
      Location.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'ForemanOpenscap::ScapContent',
        'taxable_taxonomies.taxable_id' => id
      ).pluck("#{Location.arel_table.name}.id")
    end

    def used_organization_ids
      Organization.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'ForemanOpenscap::ScapContent',
        'taxable_taxonomies.taxable_id' => id
      ).pluck("#{Location.arel_table.name}.id")
    end

    def to_label
      title
    end

    def as_json(*args)
      hash = super
      hash["scap_file"] = scap_file.to_s.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
    end

    def fetch_profiles
      api = ProxyAPI::Openscap.new(:url => proxy_url)
      profiles = api.fetch_policies_for_scap_content(scap_file)
      profiles
    end
  end
end
