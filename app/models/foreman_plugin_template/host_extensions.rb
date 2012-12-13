# Ensure that module is namespaced with plugin name
module ForemanPluginTemplate
	module HostExtensions
		extend ActiveSupport::Concern

		included do
		#  some_class_method
		end

	    module ClassMethods
		  # ...
		end

		module InstanceMethods
		  # ...
		  def new_instance_method
		    #
		  end
		  # or overwrite existing method
		end
	end
end
