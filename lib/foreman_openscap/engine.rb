module ForemanOpenscap
  def self.with_katello?
    Foreman::Plugin.installed?("katello")
  end

  class Engine < ::Rails::Engine
    engine_name 'foreman_openscap'
    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models"]
    config.autoload_paths += Dir["#{config.root}/app/graphql"]
    config.autoload_paths += Dir["#{config.root}/app/lib"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir["#{config.root}/test/"]

    # Add any db migrations
    initializer "foreman_openscap.load_app_instance_data" do |app|
      ForemanOpenscap::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    assets_to_precompile =
      Dir.chdir(root) do
        Dir['app/assets/javascripts/foreman_openscap/**/*', 'app/assets/stylesheets/foreman_openscap/**/*'].map do |f|
          f.split(File::SEPARATOR, 4).last
        end
      end

    initializer 'foreman_openscap.assets.precompile' do |app|
      app.config.assets.precompile += assets_to_precompile
    end

    initializer 'foreman_openscap.configure_assets', :group => :assets do
      SETTINGS[:foreman_openscap] =
        { :assets => { :precompile => assets_to_precompile } }
    end

    initializer 'foreman_openscap.apipie' do
      Apipie.configuration.checksum_path += ['/compliance/']
    end

    initializer 'foreman_openscap.filter_large_params' do |app|
      app.config.filter_parameters += %i[logs scap_file oval_results] if app.config.filter_parameters
    end

    initializer 'foreman_openscap.register_plugin', :before => :finisher_hook do |app|
      Foreman::Plugin.register :foreman_openscap do
        requires_foreman '>= 3.3'

        apipie_documented_controllers ["#{ForemanOpenscap::Engine.root}/app/controllers/api/v2/compliance/*.rb"]

        register_custom_status ForemanOpenscap::ComplianceStatus
        register_custom_status ForemanOpenscap::OvalStatus

        # Add permissions
        security_block :foreman_openscap do
          permission :view_arf_reports, { :arf_reports => %i[index show parse_html show_html
                                                             parse_bzip auto_complete_search download_html],
                                          'api/v2/compliance/arf_reports' => %i[index show download download_html],
                                          :compliance_hosts => [:show] },
                     :resource_type => 'ForemanOpenscap::ArfReport'
          permission :destroy_arf_reports, { :arf_reports => %i[destroy delete_multiple submit_delete_multiple],
                                             'api/v2/compliance/arf_reports' => [:destroy] },
                     :resource_type => 'ForemanOpenscap::ArfReport'
          permission :create_arf_reports, { 'api/v2/compliance/arf_reports' => [:create] },
                     :resource_type => 'ForemanOpenscap::ArfReport'

          permission :view_policies, { :policies => %i[index show parse auto_complete_search],
                                       :policy_dashboard => [:index],
                                       :compliance_dashboard        => [:index],
                                       'api/v2/compliance/policies' => %i[index show content] },
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :edit_policies, { :policies => %i[edit update scap_content_selected],
                                       'api/v2/compliance/policies' => [:update] },
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :create_policies, { :policies => %i[new create],
                                         'api/v2/compliance/policies' => [:create] },
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :destroy_policies, { :policies => [:destroy],
                                          'api/v2/compliance/policies' => [:destroy] },
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :assign_policies, { :policies => %i[select_multiple_hosts update_multiple_hosts
                                                         disassociate_multiple_hosts
                                                         remove_policy_from_multiple_hosts] },
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :view_scap_contents, { :scap_contents => %i[index show auto_complete_search],
                                            'api/v2/compliance/scap_contents' => %i[index show xml],
                                            'api/v2/compliance/scap_content_profiles' => %i[index] },
                     :resource_type => 'ForemanOpenscap::ScapContent'
          permission :edit_scap_contents, { :scap_contents => %i[edit update],
                                            'api/v2/compliance/scap_contents' => [:update] },
                     :resource_type => 'ForemanOpenscap::ScapContent'
          permission :create_scap_contents, { :scap_contents => %i[new create],
                                              'api/v2/compliance/scap_contents' => %i[create bulk_upload] },
                     :resource_type => 'ForemanOpenscap::ScapContent'
          permission :destroy_scap_contents, { :scap_contents => [:destroy],
                                               'api/v2/compliance/scap_contents' => [:destroy] },
                     :resource_type => 'ForemanOpenscap::ScapContent'
          permission :edit_hosts, { :hosts => %i[openscap_proxy_changed
                                                 select_multiple_openscap_proxy
                                                 update_multiple_openscap_proxy] },
                     :resource_type => "Host"
          permission :view_hosts, { 'api/v2/hosts' => [:policies_enc] }, :resource_type => 'Host'
          permission :edit_hostgroups, { :hostgroups => [:openscap_proxy_changed] }, :resource_type => "Hostgroup"
          permission :create_tailoring_files, { :tailoring_files => %i[create new],
                                                'api/v2/compliance/tailoring_files' => [:create] },
                     :resource_type => 'ForemanOpenscap::TailoringFile'
          permission :view_tailoring_files, { :tailoring_files => %i[index auto_complete_search xml],
                                              :policies => [:tailoring_file_selected],
                                              'api/v2/compliance/tailoring_files' => %i[show xml index],
                                              'api/v2/compliance/policies' => [:tailoring],
                                              'api/v2/compliance/scap_content_profiles' => %i[index] },
                     :resource_type => 'ForemanOpenscap::TailoringFile'
          permission :edit_tailoring_files, { :tailoring_files => %i[edit update],
                                              'api/v2/compliance/tailoring_files' => [:update] },
                     :resource_type => 'ForemanOpenscap::TailoringFile'
          permission :destroy_tailoring_files, { :tailoring_files => [:destroy],
                                                 'api/v2/compliance/tailoring_files' => [:destroy] },
                     :resource_type => 'ForemanOpenscap::TailoringFile'
          permission :view_openscap_proxies, { :openscap_proxies => [:openscap_spool] },
                     :resource_type => 'SmartProxy'
          permission :view_oval_contents, { 'api/v2/compliance/oval_contents' => %i[index show] },
                     :resource_type => 'ForemanOpenscap::OvalContent'
          permission :edit_oval_contents, { 'api/v2/compliance/oval_contents' => %i[update sync] },
                     :resource_type => 'ForemanOpenscap::OvalContent'
          permission :create_oval_contents, { 'api/v2/compliance/oval_contents' => %i[create] },
                     :resource_type => 'ForemanOpenscap::OvalContent'
          permission :destroy_oval_contents, { 'api/v2/compliance/oval_contents' => %i[destroy] },
                     :resource_type => 'ForemanOpenscap::OvalContent'
          permission :view_oval_policies, { 'api/v2/compliance/oval_policies' => %i[index show oval_content] },
                     :resource_type => 'ForemanOpenscap::OvalPolicy'
          permission :edit_oval_policies, { 'api/v2/compliance/oval_policies' => %i[update assign_hosts assign_hostgroups] },
                     :resource_type => 'ForemanOpenscap::OvalPolicy'
          permission :create_oval_policies, { 'api/v2/compliance/oval_policies' => %i[create] },
                     :resource_type => 'ForemanOpenscap::OvalPolicy'
          permission :destroy_oval_policies, { 'api/v2/compliance/oval_policies' => %i[destroy] },
                     :resource_type => 'ForemanOpenscap::OvalPolicy'
          permission :create_oval_policies, { 'api/v2/compliance/oval_reports' => %i[create] },
                     :resource_type => 'ForemanOpenscap::Cve'
        end

        role "Compliance viewer", %i[view_arf_reports view_policies view_scap_contents view_tailoring_files view_openscap_proxies],
             "Role granting read permissions to policy configuration, scan results and downloading reports."
        role "Compliance manager", %i[view_arf_reports view_policies view_scap_contents
                                      destroy_arf_reports edit_policies edit_scap_contents assign_policies
                                      create_policies create_scap_contents destroy_policies destroy_scap_contents
                                      create_tailoring_files view_tailoring_files edit_tailoring_files destroy_tailoring_files
                                      view_openscap_proxies],
             "Role granting all permissions to compliance features to non-admin users."
        role "Create ARF report", [:create_arf_reports] # special as only Proxy can create

        add_all_permissions_to_default_roles

        # add menu entries
        divider :top_menu, :caption => N_('Compliance'), :parent => :hosts_menu
        menu :top_menu, :compliance_policies, :caption => N_('Policies'),
                                              :url_hash => { :controller => :policies, :action => :index },
                                              :parent => :hosts_menu
        menu :top_menu, :compliance_contents, :caption => N_('SCAP contents'),
                                              :url_hash => { :controller => :scap_contents, :action => :index },
                                              :parent => :hosts_menu
        menu :top_menu, :compliance_reports, :caption => N_('Reports'),
                                             :url_hash => { :controller => :arf_reports, :action => :index },
                                             :parent => :hosts_menu
        menu :top_menu, :compliance_files, :caption => N_('Tailoring Files'),
                                           :url_hash => { :controller => :tailoring_files, :action => :index },
                                           :parent => :hosts_menu
        menu :labs_menu, :oval_contents, :caption => N_('OVAL Contents'),
                                         :url_hash => { :controller => 'react', :action => 'index' },
                                         :url => '/experimental/compliance/oval_contents',
                                         :parent => :lab_features_menu

        menu :labs_menu, :oval_policies, :caption => N_('OVAL Policies'),
                                         :url_hash => { :controller => 'react', :action => 'index' },
                                         :url => '/experimental/compliance/oval_policies',
                                         :parent => :lab_features_menu
        # add dashboard widget
        widget 'compliance_host_reports_widget',
               :name => N_('Latest Compliance Reports'), :sizex => 6, :sizey => 1
        widget 'compliance_reports_breakdown_widget',
               :name => N_('Compliance Reports Breakdown'), :sizex => 4, :sizey => 1

        # As 'arf_report_breakdowns' is a view and does not appear in schema.rb, db:test:prepare will not create the view
        # which will make the following tests fail.
        tests_to_skip({ "DashboardIntegrationTest" => ["dashboard page", "dashboard link hosts that had performed modifications",
                                                       "dashboard link hosts in error state", "dashboard link good host reports",
                                                       "dashboard link hosts that had pending changes", "dashboard link out of sync hosts",
                                                       "dashboard link hosts with no reports", "dashboard link hosts with alerts disabled",
                                                       "widgets not in dashboard show up in list"] })
        # strong params
        parameter_filter ::Host::Managed, :openscap_proxy_id, :openscap_proxy
        parameter_filter ::Hostgroup, :openscap_proxy_id, :openscap_proxy
        parameter_filter Log, :result

        proxy_description = N_('OpenSCAP Proxy to use for fetching SCAP content and uploading ARF reports. Leave blank and override appropriate parameters when using proxy load balancer.')

        smart_proxy_for ::Hostgroup, :openscap_proxy,
                        :feature => 'Openscap',
                        :label => N_('OpenSCAP Proxy'),
                        :description => proxy_description,
                        :api_description => N_('ID of OpenSCAP Proxy')
        smart_proxy_for Host::Managed, :openscap_proxy,
                        :feature => 'Openscap',
                        :label => N_('OpenSCAP Proxy'),
                        :description => proxy_description,
                        :api_description => N_('ID of OpenSCAP Proxy')

        add_controller_action_scope('Api::V2::HostsController', :index) do |base_scope|
          base_scope.preload(:policies)
        end

        add_controller_action_scope('HostsController', :index) do |base_scope|
          base_scope.preload(:policies)
        end

        register_global_js_file 'global'

        register_graphql_query_field :oval_contents, '::Types::OvalContent', :collection_field
        register_graphql_query_field :oval_content, '::Types::OvalContent', :record_field
        register_graphql_query_field :oval_policies, '::Types::OvalPolicy', :collection_field
        register_graphql_query_field :oval_policy, '::Types::OvalPolicy', :record_field
        register_graphql_query_field :cves, '::Types::Cve', :collection_field

        register_graphql_mutation_field :delete_oval_policy, ::Mutations::OvalPolicies::Delete
        register_graphql_mutation_field :delete_oval_content, ::Mutations::OvalContents::Delete
        register_graphql_mutation_field :update_oval_policy, ::Mutations::OvalPolicies::Update
        register_graphql_mutation_field :create_oval_policy, ::Mutations::OvalPolicies::Create

        register_facet ForemanOpenscap::Host::OvalFacet, :oval_facet do
          configure_host do
            extend_model ForemanOpenscap::OvalFacetHostExtensions
          end

          configure_hostgroup(ForemanOpenscap::Hostgroup::OvalFacet) do
            extend_model ForemanOpenscap::OvalFacetHostgroupExtensions
          end
        end

        describe_host do
          multiple_actions_provider :compliance_host_multiple_actions
          overview_buttons_provider :compliance_host_overview_button
        end
      end
    end

    initializer 'foreman_openscap.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_openscap'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      ::Api::V2::HostsController.send(:include, ForemanOpenscap::Api::V2::HostsControllerExtensions)
      ::Host::Managed.send(:include, ForemanOpenscap::OpenscapProxyExtensions)
      ::Host::Managed.send(:include, ForemanOpenscap::OpenscapProxyCoreExtensions)
      ::Host::Managed.send(:prepend, ForemanOpenscap::HostExtensions)
      HostsHelper.send(:prepend, ForemanOpenscap::HostsHelperExtensions)
      ::Hostgroup.send(:include, ForemanOpenscap::OpenscapProxyExtensions)
      ::Hostgroup.send(:include, ForemanOpenscap::OpenscapProxyCoreExtensions)
      ::Hostgroup.send(:include, ForemanOpenscap::HostgroupExtensions)
      SmartProxy.send(:include, ForemanOpenscap::SmartProxyExtensions)
      HostsController.send(:prepend, ForemanOpenscap::HostsControllerExtensions)
      HostsController.send(:include, ForemanOpenscap::HostsAndHostgroupsControllerExtensions)
      HostgroupsController.send(:include, ForemanOpenscap::HostsAndHostgroupsControllerExtensions)
      Log.send(:include, ForemanOpenscap::LogExtensions)
      BookmarkControllerValidator.send(:prepend, ForemanOpenscap::BookmarkControllerValidatorExtensions)
      ProxyStatus.status_registry.add(ProxyStatus::OpenscapSpool)

      if ForemanOpenscap.with_remote_execution?
        options = {
          :description => N_("Run OpenSCAP scan"),
          :provided_inputs => "policies"
        }

        oval_options = {
          :description => N_("Run OVAL scan")
        }

        if Gem::Version.new(ForemanRemoteExecution::VERSION) >= Gem::Version.new('1.2.3')
          options[:host_action_button] = true
          oval_options[:host_action_button] = (!::Foreman.in_rake? && ActiveRecord::Base.connection.table_exists?(:settings)) ? (Setting.find_by(:name => 'lab_features')&.value || false) : false
        end

        RemoteExecutionFeature.register(:foreman_openscap_run_scans, N_("Run OpenSCAP scan"), options)
        RemoteExecutionFeature.register(:foreman_openscap_run_oval_scans, N_("Run OVAL scan"), oval_options)
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanOpenscap::Engine.load_seed
      end
    end
  end

  def self.table_name_prefix
    "foreman_openscap_"
  end

  def self.use_relative_model_naming?
    true
  end

  def self.with_remote_execution?
    RemoteExecutionFeature rescue false
  end
end
