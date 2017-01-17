module ForemanOpenscap
  module HostgroupExtensions
    extend ActiveSupport::Concern

    included do
      has_one :asset, :as => :assetable, :class_name => "::ForemanOpenscap::Asset", dependent: :destroy
      has_many :asset_policies, :through => :asset, :class_name => "::ForemanOpenscap::AssetPolicy"
      has_many :policies, :through => :asset_policies, :class_name => "::ForemanOpenscap::Policy"
    end

    def inherited_policies
      return [] unless parent

      ancestors.inject([]) do |policies, hostgroup|
        policies += hostgroup.policies
      end.uniq
    end

    unless defined?(Katello::System)
      private

      def inherited_ancestry_attribute(attribute)
        if ancestry.present?
          self[attribute] || self.class.sort_by_ancestry(ancestors.where("#{attribute} is not NULL")).last.try(attribute)
        else
          self.send(attribute)
        end
      end
    end
  end
end
