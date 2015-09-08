module ForemanOpenscap
  class ScapContentProfile < ActiveRecord::Base
    belongs_to :scap_content
    has_many :policies
  end
end
