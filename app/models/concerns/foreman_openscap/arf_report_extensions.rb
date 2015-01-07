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
    included do
      has_one :auditable_host, :through => :asset
      has_one :host, :through => :auditable_host

      scoped_search :in => :asset, :on => :name, :complete_value => :true, :rename => "host"

      scope :hosts, lambda { includes(:policy, :arf_report_breakdown) }

      scope :latest, lambda { includes(:host, :policy, :arf_report_breakdown).limit(5).order("scaptimony_arf_reports.created_at DESC") }
    end
  end
end
