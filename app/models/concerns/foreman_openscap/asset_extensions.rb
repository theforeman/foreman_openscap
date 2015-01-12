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
      scope :to_hosts, lambda { where(:assetable_type => 'Host::Base') }

      def self.hosts
        host_ids = self.to_hosts.pluck(:assetable_id)
        Host.find(host_ids)
      end
    end

    def host
      fetch_asset('Host::Base')
    end

    def container
      fetch_asset('Container')
    end

    def hostgroup
      fetch_asset('Hostgroup')
    end

    private

    def fetch_asset(type)
      if assetable_type == type
        assetable
      end
    end

  end
end
