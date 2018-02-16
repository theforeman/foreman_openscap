blueprints = [
  {
    group: N_('Jobs'),
    name: 'openscap_scan_succeeded',
    message: N_("OpenSCAP scan on %{hosts_count} host(s) has finished successfully"),
    level: 'success',
    actions:
    {
      links:
      [
        path_method: :job_invocation_path,
        title: N_('Job Details')
      ]
    }
  }
]

blueprints.each { |blueprint| UINotifications::Seed.new(blueprint).configure }
