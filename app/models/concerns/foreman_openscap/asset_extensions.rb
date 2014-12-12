#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

require 'scaptimony/asset'
require 'scaptimony/auditable_host'

module ForemanOpenscap
  module AssetExtensions
    extend ActiveSupport::Concern
    included do
      has_one :auditable_host, :inverse_of => :asset
      has_one :host, :through => :auditable_host

      scope :hosts, joins(:auditable_host)
    end
  end
end
