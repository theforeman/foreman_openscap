#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

require 'scaptimony/scap_content'

module ForemanOpenscap
  module ScapContentExtensions
    extend ActiveSupport::Concern
    include Authorizable
    include Taxonomix
    included do
      attr_accessible :location_ids, :organization_ids

      default_scope {
        with_taxonomy_scope do
          order("scaptimony_scap_contents.title")
        end
      }
    end

    def used_location_ids
      Location.joins(:taxable_taxonomies).where(
          'taxable_taxonomies.taxable_type' => 'Scaptimony::ScapContent',
          'taxable_taxonomies.taxable_id' => id).pluck("#{Location.arel_table.name}.id")
    end

    def used_organization_ids
      Organization.joins(:taxable_taxonomies).where(
          'taxable_taxonomies.taxable_type' => 'Scaptimony::ScapContent',
          'taxable_taxonomies.taxable_id' => id).pluck("#{Location.arel_table.name}.id")
    end
  end
end
