module ForemanOpenscap
  class OvalContent < ApplicationRecord
    audited :except => [:scap_file]
    include Authorizable
    include Taxonomix
    include ScapFileContent

    before_destroy EnsureNotUsedBy.new(:oval_policies)

    scoped_search :on => :name, :complete_value => true

    has_many :oval_policies
    validates :name, :presence => true, :length => { :maximum => 255 }, uniqueness: true
    validates :url, :format => { :with => %r{\Ahttps?://} }, :allow_blank => true

    before_validation :fetch_remote_content, :if => lambda { |oval_content| oval_content.url.present? }

    def to_h
      { :id => id, :name => name, :original_filename => original_filename, :changed_at => changed_at }
    end

    private

    def fetch_remote_content
      ForemanOpenscap::Oval::SyncOvalContents.new.sync self
    end
  end
end
