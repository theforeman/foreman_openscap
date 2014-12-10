#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module ::Scaptimony
  class AuditableHost < ActiveRecord::Base
    # Links Foreman's Host table with SCAPtimony's Asset table
    belongs_to :asset, :inverse_of => :auditable_host
    belongs_to_host :inverse_of => :auditable_host
  end
end
