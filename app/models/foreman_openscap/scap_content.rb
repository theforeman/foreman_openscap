require 'digest/sha2'
require 'openscap/ds/sds'
require 'openscap/source'
require 'openscap/xccdf/benchmark'

module ForemanOpenscap
  class DataStreamValidator < ActiveModel::Validator
    def validate(scap_content)
      return unless scap_content.scap_file_changed?

      allowed_type = 'SCAP Source Datastream'
      if scap_content.source.try(:type) != allowed_type
        scap_content.errors[:base] << _("Uploaded file is not #{allowed_type}.")
        return false
      end

      begin
        scap_content.source.validate!
      rescue OpenSCAP::OpenSCAPError => e
        scap_content.errors[:base] << e.message
      end

      unless (scap_content.scap_content_profiles.map(&:profile_id) - scap_content.benchmark_profiles.profiles.keys).empty?
        scap_content.errors[:base] << _('Changed file does not include existing SCAP Content profiles.')
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

    default_scope {
      with_taxonomy_scope do
        order("foreman_openscap_scap_contents.title")
      end
    }

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

    def source
      @source ||= source_init
    end

    def digest
      self[:digest] ||= Digest::SHA256.hexdigest "#{scap_file}"
    end

    # returns OpenSCAP::Xccdf::Benchmark with profiles.
    def benchmark_profiles
      sds          = ::OpenSCAP::DS::Sds.new(source)
      bench_source = sds.select_checklist!
      benchmark = ::OpenSCAP::Xccdf::Benchmark.new(bench_source)
      sds.destroy
      benchmark
    end

    private
    def source_init
      OpenSCAP.oscap_init
      OpenSCAP::Source.new(:content => scap_file)
    end

    def create_profiles
      bench = benchmark_profiles
      bench.profiles.each { |key, profile|
        scap_content_profiles.find_or_create_by_profile_id_and_title(key, profile.title)
      }
      bench.destroy

    end

    def redigest
      self[:digest] = Digest::SHA256.hexdigest "#{scap_file}"
    end

  end
end
