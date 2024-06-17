class RemoveOvalPermissions < ActiveRecord::Migration[6.1]
  def up
    ['ForemanOpenscap::OvalPolicy', 'ForemanOpenscap::OvalContent', 'ForemanOpenscap::Cve'].each do |resource_type|
      Permission.where(resource_type: resource_type).each do |permission|
        # Filter has before_destroy check if it belongs to a locked role (e.g. default one). Since this is a cleanup, we don't care.
        permission.filters.delete_all
        # Permission should remove Filterings on destroy
        permission.destroy
      end
    end
    # Not a permission, but still a leftover from OVAL removal
    if ForemanOpenscap.with_remote_execution?
      oval_feature = RemoteExecutionFeature.find_by(label: 'foreman_openscap_run_oval_scans')
      oval_scan_template = Template.find_by(name: 'Run OVAL scans')
      if oval_scan_template
        TemplateInvocation.where(template_id: oval_scan_template.id).delete_all
        TemplateInput.where(template_id: oval_scan_template.id).delete_all
      end
      JobInvocation.where(remote_execution_feature_id: oval_feature.id).delete_all if oval_feature
      oval_feature&.destroy
      oval_scan_template&.delete
    end
  end
end
