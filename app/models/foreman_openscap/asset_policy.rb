module ForemanOpenscap
  class AssetPolicy < ApplicationRecord
    belongs_to :policy
    belongs_to :asset
  end
end
