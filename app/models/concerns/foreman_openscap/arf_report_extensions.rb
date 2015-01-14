#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

require 'scaptimony/arf_report'

module ForemanOpenscap
  module ArfReportExtensions
    extend ActiveSupport::Concern
    include Taxonomix
    included do

      has_one :host, :through => :asset, :as => :assetable
      after_save :assign_locations_organizations

      scope :hosts, lambda { includes(:policy, :arf_report_breakdown) }
      scope :latest, lambda { limit(5).order("scaptimony_arf_reports.created_at DESC") }

      scoped_search :in => :asset, :on => :name, :complete_value => :true, :rename => "host"

      default_scope {
        with_taxonomy_scope do
          order("scaptimony_arf_reports.created_at DESC")
        end
      }
    end

    def host
      assetable
    end

    def assign_locations_organizations
      if host
        self.locations = [host.location]
        self.organizations = [host.organization]
      end
    end
  end
end
