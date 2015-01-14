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

module ForemanOpenscap
  module AssetExtensions
    extend ActiveSupport::Concern
    included do
      scope :hosts, where(:assetable_type => 'Host::Base')
    end

    def host
      fetch_asset('Host::Base')
    end

    private
    def fetch_asset(type)
      assetable if assetable_type == type
    end
  end
end
