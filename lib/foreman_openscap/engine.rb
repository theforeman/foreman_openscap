require 'deface'
require 'scaptimony/engine'

module ForemanOpenscap
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer "foreman_openscap.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Scaptimony::Engine.paths['db/migrate'].existent
      app.config.paths['db/migrate'] += ForemanOpenscap::Engine.paths['db/migrate'].existent
    end

    initializer 'foreman_openscap.assets.precompile' do |app|
      app.config.assets.precompile += %w(
        'foreman_openscap/policy_edit.js',
        'foreman_openscap/policy.css'
      )
    end

    initializer 'foreman_openscap.configure_assets', :group => :assets do
      SETTINGS[:foreman_openscap] =
          {:assets => {:precompile => ['foreman_openscap/policy_edit.js',
                                       'foreman_openscap/policy.css']}}
    end

    initializer 'foreman_openscap.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_openscap do
        requires_foreman '>= 1.5'

        # Add permissions
        security_block :foreman_openscap do
          permission :view_arf_reports, {:scaptimony_arf_reports => [:index, :show],
                                         :scaptimony_policies => [:index, :show],
                                         :scaptimony_scap_contents => [:index, :show],
                                        }
          permission :edit_compliance, {:scaptimony_arf_reports => [:destroy],
                                        :scaptimony_policies => [:new, :create, :edit, :update, :destroy,
                                          :select_multiple_hosts, :upldate_multiple_hosts],
                                        :scaptimony_scap_contents => [:new, :create, :edit, :update]
                                       }
        end

        role "View compliance reports", [:view_arf_reports]
        role "Edit compliance policies", [:edit_compliance]

        #add menu entries
        divider :top_menu, :caption => N_('Compliance'), :parent => :hosts_menu
        menu :top_menu, :compliance_policies, :caption => N_('Policies'),
             :url_hash => {:controller => :'scaptimony_policies', :action => :index },
             :parent => :hosts_menu
        menu :top_menu, :compliance_contents, :caption => N_('SCAP contents'),
             :url_hash => {:controller => :'scaptimony_scap_contents', :action => :index },
             :parent => :hosts_menu
        menu :top_menu, :compliance_reports, :caption => N_('Reports'),
             :url_hash => {:controller => :'scaptimony_arf_reports', :action => :index },
             :parent   => :hosts_menu

        # add dashboard widget
        widget 'foreman_openscap_host_reports_widget', :name => N_('OpenSCAP Host reports widget'), :sizex => 4, :sizey =>1
        widget 'foreman_openscap_reports_breakdown_widget', :name => N_('OpenSCAP Host reports widget'), :sizex => 4, :sizey =>1
      end
    end

    #Include concerns in this config.to_prepare block
    config.to_prepare do
      Host::Managed.send(:include, ForemanOpenscap::HostExtensions)
      HostsHelper.send(:include, ForemanOpenscap::HostsHelperExtensions)
      ::Scaptimony::ArfReport.send(:include, ForemanOpenscap::ArfReportExtensions)
      ::Scaptimony::Asset.send(:include, ForemanOpenscap::AssetExtensions)
      ::Scaptimony::Policy.send(:include, ForemanOpenscap::PolicyExtensions)
      ::Scaptimony::ScapContent.send(:include, ForemanOpenscap::ScapContentExtensions)
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        Scaptimony::Engine.load_seed
        ForemanOpenscap::Engine.load_seed
      end
    end

  end
end
