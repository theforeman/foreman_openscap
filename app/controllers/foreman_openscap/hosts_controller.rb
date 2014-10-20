module ForemanOpenscap

  # Example: Plugin's HostsController inherits from Foreman's HostsController
  class HostsController < ::HostsController

    # change layout if needed
    # layout 'foreman_openscap/layouts/new_layout'

    def openscap
      # automatically renders view/foreman_openscap/hosts/openscap
    end

  end
end
