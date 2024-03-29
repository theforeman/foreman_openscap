class PoliciesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Policy

  before_action :find_by_id, :only => %i[show edit update parse destroy]
  before_action :find_multiple, :only => %i[select_multiple_hosts update_multiple_hosts disassociate_multiple_hosts remove_policy_from_multiple_hosts]
  before_action :find_tailoring_file, :only => [:tailoring_file_selected]

  def model_of_controller
    ::ForemanOpenscap::Policy
  end

  def index
    @policies = resource_base_search_and_page.search_for(params[:search])
                                             .includes(:scap_content, :scap_content_profile, :tailoring_file, :tailoring_file_profile)
    if @policies.empty? && ForemanOpenscap::ScapContent.unconfigured?
      redirect_to scap_contents_path
    end
  end

  def new
    @policy = ::ForemanOpenscap::Policy.new(:wizard_initiated => true)
  end

  def show
  end

  def parse
    self.response_body = @policy.to_html
  end

  def create
    @policy = ::ForemanOpenscap::Policy.new(policy_params)
    ForemanOpenscap::LookupKeyOverrider.new(@policy).override if @policy.current_step?('Policy Attributes')
    if @policy.wizard_completed? && @policy.save
      process_success :success_redirect => policies_path
    elsif @policy.errors.none? && @policy.valid?
      render('new') && return
    else
      @policy.rewind_step
      process_error :object => @policy
    end
  end

  def edit
  end

  def update
    if @policy.change_deploy_type(policy_params)
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
      render :partial => 'scap_content_results', :locals => { :policy => @policy }
    end
  end

  def tailoring_file_selected
    @policy ||= ::ForemanOpenscap::Policy.new
    render :partial => 'tailoring_file_selected', :locals => { :policy => @policy, :tailoring_file => @tailoring_file }
  end

  def select_multiple_hosts
  end

  def update_multiple_hosts
    if (id = params['policy']['id'])
      policy = ::ForemanOpenscap::Policy.find(id)
      policy.host_ids = policy.host_ids + @hosts.pluck(:id)
      if policy.save
        success _("Updated hosts: Assigned with compliance policy: %s") % policy.name
        # We prefer to go back as this does not lose the current search
        return redirect_to hosts_path
      else
        return process_error :object => policy, :redirect => hosts_path
      end
    else
      error _('No compliance policy selected.')
      redirect_to(select_multiple_hosts_policies_path)
    end
  end

  def disassociate_multiple_hosts
  end

  def remove_policy_from_multiple_hosts
    if (id = params.fetch(:policy, {})[:id])
      policy = ::ForemanOpenscap::Policy.find(id)
      policy.unassign_hosts(@hosts)
      success _("Updated hosts: Unassigned from compliance policy '%s'") % policy.name
    else
      error _('No valid policy ID provided')
    end
    redirect_to hosts_path
  end

  private

  def find_by_id
    @policy = resource_base.find(params[:id])
  end

  def find_tailoring_file
    @tailoring_file = ForemanOpenscap::TailoringFile.find(params[:tailoring_file_id]) if params[:tailoring_file_id].present?
  end

  def multiple_with_filter?
    params.key?(:search)
  end
  
  def find_multiple
    if params.key?(:host_names) || params.key?(:host_ids) || multiple_with_filter?
      @hosts = Host.search_for(params[:search]) if multiple_with_filter?
      @hosts ||= Host.merge(Host.where(id: params[:host_ids]).or(Host.where(name: params[:host_names])))
      if @hosts.empty?
        error _('No hosts were found with that id, name or query filter')
        redirect_to(hosts_path)
        return false
      end
    else
      error _('No hosts selected')
      redirect_to(hosts_path) && (return false)
    end
    return @hosts
  rescue => e
    error _("Something went wrong while selecting hosts - %s") % e
    logger.debug e.message
    logger.debug e.backtrace.join("\n")
    redirect_to(hosts_path) && (return false)
  end

  def action_permission
    case params[:action]
    when 'parse', 'tailoring_file_selected'
      :view
    else
      super
    end
  end
end
