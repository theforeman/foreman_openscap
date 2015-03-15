#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

require 'scaptimony/arf_reports_helper'
require 'foreman_openscap/helper'

module Api
  module V2
    module Compliance

      class ArfReportsController < V2::BaseController
        include Api::Version2
        include Foreman::Controller::SmartProxyAuth

        add_puppetmaster_filters :create

        api :POST, "/arf/:cname/:policy_id/:date", N_("Upload an ARF report")
        param :cname, :identifier, :required => true
        param :policy_id, :identifier, :required => true
        param :date, :identifier, :required => true

        def create
          asset = ForemanOpenscap::Helper::get_asset(params[:cname], params[:policy_id])
          arf_bzip2 = request.body.read
          arf_bzip2_size = request.body.size
          Scaptimony::ArfReportsHelper.create_arf(asset, params, arf_bzip2, arf_bzip2_size)
          render :json => { :result => :OK, :received => arf_bzip2_size }
        end

        def check_content_type
          # Well, this is unfortunate. Parent class asserts that content-type is
          # application/json. While we want to have content-type text/xml. We
          # also need the content-encoding to equal with x-bzip2. However, when
          # the framework sees text/xml, it will rewrite it to application/xml.
          # What's worse, a framework will try to parse body as an utf8 string,
          # no matter what content-encoding says. Let's pass content-type arf-bzip2
          # and move forward.
          super unless
            request.content_type.end_with? 'arf-bzip2' and
            request.env['HTTP_CONTENT_ENCODING'] == 'x-bzip2'
        end
      end
    end
  end
end
