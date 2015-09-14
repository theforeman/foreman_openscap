require 'deface'

module ForemanOpenscap
  class Engine < ::Rails::Engine
    engine_name 'foreman_openscap'
    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer "foreman_openscap.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += ForemanOpenscap::Engine.paths['db/migrate'].existent
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
          {:assets => {:precompile => assets_to_precompile}}
    end

    initializer 'foreman_openscap.apipie' do
      Apipie.configuration.checksum_path += ['/compliance/']
    end

    initializer 'foreman_openscap.register_plugin', :after => :finisher_hook do |app|
      Foreman::Plugin.register :foreman_openscap do
        requires_foreman '>= 1.5'

        apipie_documented_controllers ["#{ForemanOpenscap::Engine.root}/app/controllers/api/v2/compliance/*.rb"]

        # Add permissions
        security_block :foreman_openscap do
          permission :view_arf_reports, {:arf_reports => [:index, :show, :parse, :auto_complete_search],
                                         'api/v2/compliance/arf_reports' => [:index, :show],
                                         :compliance_hosts => [:show]}
          permission :destroy_arf_reports, {:arf_reports => [:destroy],
                                            'api/v2/compliance/arf_reports' => [:destroy]}
          permission :create_arf_reports, {'api/v2/compliance/arf_reports' => [:create]}

          permission :view_policies, {:policies => [:index, :show, :parse, :auto_complete_search],
                                                 :policy_dashboard => [:index],
                                                 :compliance_dashboard        => [:index],
                                                 'api/v2/compliance/policies' => [:index, :show, :content]},
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :edit_policies, {:policies => [:edit, :update, :scap_content_selected],
                                                 'api/v2/compliance/policies' => [:update]},
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :create_policies, {:policies => [:new, :create],
                                                   'api/v2/compliance/policies' => [:create]},
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :destroy_policies, {:policies => [:destroy],
                                                    'api/v2/compliance/policies' => [:destroy]},
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :assign_policies, {:policies => [:select_multiple_hosts, :update_multiple_hosts,
                                                                            :disassociate_multiple_hosts,
                                                                            :remove_policy_from_multiple_hosts]},
                     :resource_type => 'ForemanOpenscap::Policy'
          permission :view_scap_contents, {:scap_contents => [:index, :show, :auto_complete_search],
                                                      'api/v2/compliance/scap_contents' => [:index, :show]},
                     :resource_type => 'ForemanOpenscap::ScapContent'
          permission :edit_scap_contents, {:scap_contents => [:edit, :update],
                                                      'api/v2/compliance/scap_contents' => [:update]},
                     :resource_type => 'ForemanOpenscap::ScapContent'
          permission :create_scap_contents, {:scap_contents => [:new, :create],
                                                        'api/v2/compliance/scap_contents' => [:create]},
                     :resource_type => 'ForemanOpenscap::ScapContent'
          permission :destroy_scap_contents, {:scap_contents => [:destroy],
                                                         'api/v2/compliance/scap_contents' => [:destroy]},
                     :resource_type => 'ForemanOpenscap::ScapContent'
        end

        role "Compliance viewer", [:view_arf_reports, :view_policies, :view_scap_contents]
        role "Compliance manager", [:view_arf_reports, :view_policies, :view_scap_contents,
                                    :destroy_arf_reports, :edit_policies, :edit_scap_contents, :assign_policies,
                                    :create_policies, :create_scap_contents, :destroy_policies, :destroy_scap_contents]
        role "Create ARF report", [:create_arf_reports] # special as only Proxy can create

        #add menu entries
        divider :top_menu, :caption => N_('Compliance'), :parent => :hosts_menu
        menu :top_menu, :compliance_policies, :caption => N_('Policies'),
             :url_hash => {:controller => :'policies', :action => :index},
             :parent => :hosts_menu
        menu :top_menu, :compliance_contents, :caption => N_('SCAP contents'),
             :url_hash => {:controller => :'scap_contents', :action => :index},
             :parent => :hosts_menu
        menu :top_menu, :compliance_reports, :caption => N_('Reports'),
             :url_hash => {:controller => :'arf_reports', :action => :index},
             :parent => :hosts_menu

        # add dashboard widget
        widget 'foreman_openscap_host_reports_widget', :name => N_('OpenSCAP Host reports widget'), :sizex => 4, :sizey => 1
        widget 'foreman_openscap_reports_breakdown_widget', :name => N_('OpenSCAP Reports breakdown widget'), :sizex => 4, :sizey => 1

        # As 'arf_report_breakdowns' is a view and does not appear in schema.rb, db:test:prepare will not create the view
        # which will make the following tests fail.
        tests_to_skip ({
                          "DashboardIntegrationTest" => ["dashboard page", "dashboard link hosts that had performed modifications",
                                              "dashboard link hosts in error state", "dashboard link good host reports",
                                              "dashboard link hosts that had pending changes", "dashboard link out of sync hosts",
                                              "dashboard link hosts with no reports", "dashboard link hosts with alerts disabled",
                                              "widgets not in dashboard show up in list"]
                      })
      end
    end

    #Include concerns in this config.to_prepare block
    config.to_prepare do
      Host::Managed.send(:include, ForemanOpenscap::HostExtensions)
      HostsHelper.send(:include, ForemanOpenscap::HostsHelperExtensions)
      Hostgroup.send(:include, ForemanOpenscap::HostgroupExtensions)
      Katello::System.send(:include, ForemanOpenscap::KatelloSystemExtensions) if defined?(Katello::System)
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
end
