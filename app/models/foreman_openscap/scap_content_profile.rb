module ForemanOpenscap
  class ScapContentProfile < ApplicationRecord
    belongs_to :scap_content
    has_many :policies
    belongs_to :tailoring_file
    has_many :tailoring_file_policies, :class_name => 'ForemanOpenscap::Policy'

    scoped_search :on => :profile_id, :complete_value => true
    scoped_search :on => :title, :complete_value => true
  end
end
