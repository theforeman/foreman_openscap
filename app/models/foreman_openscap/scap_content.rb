require 'digest/sha2'

module ForemanOpenscap
  class DataStreamValidator < ActiveModel::Validator
    def validate(scap_content)
      return unless scap_content.scap_file_changed?

      unless SmartProxy.with_features('Openscap').any?
        scap_content.errors.add(:base, _('No proxy with OpenSCAP features'))
        return false
      end

      if scap_content.proxy_url.nil?
        scap_content.errors.add(:base, _('No available proxy to validate SCAP content'))
        return false
      end

      begin
        api = ProxyAPI::Openscap.new(:url => scap_content.proxy_url)
        errors = api.validate_scap_content(scap_content.scap_file)
        if errors && errors['errors'].any?
          errors['errors'].each { |error| scap_content.errors.add(:scap_file, _(error)) }
          return false
        end
      rescue *ProxyAPI::AvailableProxy::HTTP_ERRORS => e
        scap_content.errors.add(:base, _('No available proxy to validate. Returned with error: %s') % e)
        return false
      end


      unless (scap_content.scap_content_profiles.map(&:profile_id) - scap_content.fetch_profiles.keys).empty?
        scap_content.errors.add(:scap_file, _('Changed file does not include existing SCAP content profiles'))
        return false
      end
    end
  end

  class ScapContent < ActiveRecord::Base
    include Authorizable
    include Taxonomix

    attr_accessible :original_filename, :scap_file, :title, :location_ids, :organization_ids

    has_many :scap_content_profiles, :dependent => :destroy
    has_many :policies

    before_destroy EnsureNotUsedBy.new(:policies)

    validates_with DataStreamValidator
    validates :title, :presence => true
    validates :digest, :presence => true
    validates :scap_file, :presence => true

    after_save :create_profiles
    before_validation :redigest, :if => lambda { |scap_content| scap_content.persisted? && scap_content.scap_file_changed? }

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
        'taxable_taxonomies.taxable_id' => id).pluck("#{Location.arel_table.name}.id")
    end

    def used_organization_ids
      Organization.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'ForemanOpenscap::ScapContent',
        'taxable_taxonomies.taxable_id' => id).pluck("#{Location.arel_table.name}.id")
    end

    def to_label
      title
    end

    def digest
      self[:digest] ||= Digest::SHA256.hexdigest "#{scap_file}"
    end

    def fetch_profiles
      api = ProxyAPI::Openscap.new(:url => proxy_url)
      profiles = api.fetch_policies_for_scap_content(scap_file)
      profiles
    end

    def proxy_url
      @proxy_url ||= SmartProxy.with_features('Openscap').find do |proxy|
        available = ProxyAPI::AvailableProxy.new(:url => proxy.url)
        available.available?
      end.try(:url)
      @proxy_url
    end

    def as_json(*args)
      hash = super
      hash["scap_file"] = scap_file.to_s.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
    end

    private

    def create_profiles
      profiles = fetch_profiles
      profiles.each {|key, title|
        scap_content_profiles.where(:profile_id => key, :title => title).first_or_create
      }
    end

    def redigest
      self[:digest] = Digest::SHA256.hexdigest "#{scap_file}"
    end
  end
end
