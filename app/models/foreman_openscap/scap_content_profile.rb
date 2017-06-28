module ForemanOpenscap
  class ScapContentProfile < ActiveRecord::Base
    belongs_to :scap_content
    has_many :policies
    belongs_to :tailoring_file
    has_many :tailoring_file_policies, :class_name => ForemanOpenscap::Policy
  end
end
