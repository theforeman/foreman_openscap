class PoliciesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_id, :only => [:show, :edit, :update, :parse, :destroy]
  before_filter :find_multiple, :only => [:select_multiple_hosts, :update_multiple_hosts, :disassociate_multiple_hosts, :remove_policy_from_multiple_hosts]

  def model_of_controller
    ::ForemanOpenscap::Policy
  end

  def index
    @policies = resource_base
                  .search_for(params[:search], :order => params[:order])
                  .paginate(:page => params[:page], :per_page => params[:per_page])
                  .includes(:scap_content, :scap_content_profile)
    if @policies.empty? && ForemanOpenscap::ScapContent.unconfigured?
      redirect_to scap_contents_path
    end
  end

  def new
    @policy = ::ForemanOpenscap::Policy.new
  end

  def show
  end

  def parse
    self.response_body = @policy.to_html
  end

  def create
    @policy = ::ForemanOpenscap::Policy.new(params[:policy])
    if @policy.wizard_completed? && @policy.save
      process_success :success_redirect => policies_path
    else
      if @policy.valid?
        render 'new' and return
      else
        @policy.rewind_step
        process_error :object => @policy
      end
    end
  end

  def edit
  end

  def update
    if @policy.update_attributes(params[:policy])
      process_success :success_redirect => policies_path
    else
      process_error :object => @policy
    end
  end

  def destroy
    if @policy.destroy
      process_success
    else
      process_error :object => @policy
    end
  end

  def scap_content_selected
    if params[:scap_content_id] && (@scap_content = ::ForemanOpenscap::ScapContent.find(params[:scap_content_id]))
      @policy ||= ::ForemanOpenscap::Policy.new
      render :partial => 'scap_content_results', :locals => {:policy => @policy}
    end
  end

  def select_multiple_hosts; end

  def update_multiple_hosts
    if (id = params['policy']['id'])
      policy = ::ForemanOpenscap::Policy.find(id)
      policy.assign_hosts(@hosts)
      notice _("Updated hosts: Assigned with compliance policy: %s")  % policy.name
      # We prefer to go back as this does not lose the current search
      redirect_to hosts_path
    else
      error _('No compliance policy selected.')
      redirect_to(select_multiple_hosts_policies_path)
    end
  end

  def disassociate_multiple_hosts; end

  def remove_policy_from_multiple_hosts
    if (id = params.fetch(:policy, {})[:id])
      policy = ::ForemanOpenscap::Policy.find(id)
      policy.unassign_hosts(@hosts)
      notice _("Updated hosts: Unassigned from compliance policy '%s'") % policy.name
      redirect_to hosts_path
    else
      error _('No valid policy ID provided')
      redirect_to hosts_path
    end
  end

  def welcome
    @searchbar = true
    if (model_of_controller.first.nil? rescue false)
      @searchbar = false
      render :welcome rescue nil and return
    end
  rescue
    not_found
  end

  private
  def find_by_id
    @policy = resource_base.find(params[:id])
  end

  def find_multiple
    # Lets search by name or id and make sure one of them exists first
    if params[:host_ids].present?
      @hosts = Host.where("id IN (?)", params[:host_ids])
      if @hosts.empty?
        error _('No hosts were found.')
        redirect_to(hosts_path) and return false
      end
    else
      error _('No hosts selected')
      redirect_to(hosts_path) and return false
    end
    return @hosts
  rescue => e
    error _("Something went wrong while selecting hosts - %s") % (e)
    logger.debug e.message
    logger.debug e.backtrace.join("\n")
    redirect_to hosts_path and return false
  end

  def action_permission
    case params[:action]
    when 'parse'
      :view
    else
      super
    end
  end
end
