module ForemanOpenscap
    class Rule < ApplicationRecord
      validates :label, :title, :presence => true
  
      class Jail < ::Safemode::Jail
        allow :label, :title, :severity, :description, :rationale, :references, :fixes
      end
    end
  end
  