module ::Scaptimony
  class PolicyHostgroup < ActiveRecord::Base
    attr_accessible :hostgroup_id, :policy_id
    belongs_to :policy
    belongs_to :hostgroup

    validates :hostgroup_id, :uniqueness => {:scope => :policy_id}
  end
end
