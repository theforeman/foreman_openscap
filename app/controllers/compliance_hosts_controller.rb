class ComplianceHostsController < ApplicationController
  include FindCommon

  before_action :find_resource, only: :show

  def model_of_controller
    Host
  end

  def show
  end
end
