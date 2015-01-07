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
      has_one :auditable_host, :through => :asset
      has_one :host, :through => :auditable_host

      after_save :assign_locations_organizations

      scoped_search :in => :asset, :on => :name, :complete_value => :true, :rename => "host"
    end

    def assign_locations_organizations
      if host && policy
        self.locations = policy.locations + [host.location]
        self.organizations = policy.organizations + [host.organization]
      end
    end
  end
end
