organizations = Organization.unscoped.all
locations = Location.unscoped.all
if ForemanOpenscap.with_remote_execution?
  User.as_anonymous_admin do
    JobTemplate.without_auditing do
      Dir[File.join("#{ForemanOpenscap::Engine.root}/app/views/job_templates/**/*.erb")].each do |template|
        sync = !Rails.env.test? && Setting[:remote_execution_sync_templates]
        # import! was renamed to import_raw! around 1.3.1
        if JobTemplate.respond_to?('import_raw!')
          template = JobTemplate.import_raw!(File.read(template), :default => true, :lock => true, :update => sync)
        else
          template = JobTemplate.import!(File.read(template), :default => true, :lock => true, :update => sync)
        end
        next unless template.present?
        template.organizations = organizations
        template.locations = locations
      end
    end
  end
end
