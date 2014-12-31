class ScaptimonyPoliciesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_id, :only => [:show, :edit, :update, :parse, :destroy]
  before_filter :find_multiple, :only => [:select_multiple_hosts, :update_multiple_hosts]

  def model_of_controller
    ::Scaptimony::Policy
  end

  def index
    @policies = resource_base.search_for(params[:search]).includes(:scap_content, :scap_content_profile)
    if Scaptimony::ScapContent.all.count == 0 && @policies.count == 0
      redirect_to new_scaptimony_scap_content_path
    end
  end

  def new
    @policy = ::Scaptimony::Policy.new
  end

  def show
  end

  def parse
    self.response_body = @policy.to_html
  end

  def create
    @policy = ::Scaptimony::Policy.new(params[:policy])
    if @policy.save
      redirect_to edit_scaptimony_policy_path(@policy, :current_step => @policy.current_step)
    else
      process_error :object => @policy
    end
  end

  def edit
    @policy.current_step = params[:current_step]
  end

  def update
    if @policy.update_attributes(params[:policy])
      if @policy.current_step.blank?
        process_success :success_redirect => scaptimony_policies_path
      else
        redirect_to edit_scaptimony_policy_path(@policy, :current_step => @policy.current_step)
      end
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
    if params[:scap_content_id] and @scap_content = ::Scaptimony::ScapContent.find(params[:scap_content_id])
      @policy ||= ::Scaptimony::Policy.new
      render :partial => 'scap_content_results', :locals => {:policy => @policy}
    end
  end

  def select_multiple_hosts; end

  def update_multiple_hosts
    if (id = params['policy']['id'])
      policy = ::Scaptimony::Policy.find_by_id(id)
      policy.assign_hosts @hosts
      notice _("Updated hosts: Assigned with compliance policy: #{policy.name}")
      # We prefer to go back as this does not lose the current search
      redirect_to hosts_path
    else
      error _('No compliance policy selected.')
      redirect_to(select_multiple_hosts_scaptimony_policies_path)
    end
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
