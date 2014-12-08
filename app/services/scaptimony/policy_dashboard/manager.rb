#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module Scaptimony::PolicyDashboard
  module Manager
    class << self
      def map
        @widgets ||= []
        mapper = Mapper.new(@widgets)
        if block_given?
          yield mapper
        else
          mapper
        end
      end

      def widgets
        @widgets ||= Scaptimony::PolicyDashboard::Loader.load
      end
    end

    class Mapper < ::Dashboard::Manager::Mapper
    end
  end
end
