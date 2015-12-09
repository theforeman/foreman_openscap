module ForemanOpenscap
  module HostsCommonControllerExtensions
    extend ActiveSupport::Concern

    def openscap_proxy_changed
      model = if params[param_id_key].blank?
                controller_name.classify.constantize.new(params[param_model_key])
              else
                resource_base.find(params[param_id_key])
              end
      proxy_id = params[param_model_key][:openscap_proxy_id]
      instance_variable_set("@#{param_model_key}", model)
      if proxy_id.blank?
        render :partial => "form"
      else
        begin
          instance_variable_get("@#{param_model_key}").update_scap_client_params(proxy_id)
          render :partial => "form"
        rescue => e
          instance_variable_get("@#{param_model_key}").errors.add(:openscap_proxy_id, e.message)
          render :partial => "form", :status => 422
        end
      end
    end

    def action_permission
      case params[:action]
      when 'openscap_proxy_changed'
        :edit
      else
        super
      end
    end

    private

    def param_id_key
      "#{param_model_key}_id"
    end

    def param_model_key
      controller_name.singularize
    end
  end
end
