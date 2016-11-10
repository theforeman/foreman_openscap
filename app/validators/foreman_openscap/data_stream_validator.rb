module ForemanOpenscap
  class DataStreamValidator < ActiveModel::Validator
    def validate(data_stream_content)
      return unless data_stream_content.scap_file_changed?

      content_type = data_type(data_stream_content)

      unless SmartProxy.with_features('Openscap').any?
        data_stream_content.errors.add(:base, _('No proxy with OpenSCAP features'))
        return false
      end

      if data_stream_content.proxy_url.nil?
        data_stream_content.errors.add(:base, _('No available proxy to validate SCAP data stream file'))
        return false
      end

      begin
        api = ProxyAPI::Openscap.new(:url => data_stream_content.proxy_url)
        errors = api.validate_scap_file(data_stream_content.scap_file, content_type)
        if errors && errors['errors'].any?
          errors['errors'].each { |error| data_stream_content.errors.add(:scap_file, _(error)) }
          return false
        end
      rescue *ProxyAPI::AvailableProxy::HTTP_ERRORS => e
        data_stream_content.errors.add(:base, _('No available proxy to validate. Returned with error: %s') % e)
        return false
      end

      is_scap_content = content_type == 'scap_content'

      if is_scap_content && !(data_stream_content.scap_content_profiles.map(&:profile_id) - data_stream_content.fetch_profiles.keys).empty?
        data_stream_content.errors.add(:scap_file, _('Changed file does not include existing SCAP content profiles'))
        return false
      end
    end

    private

    def data_type(data_stream_content)
      data_stream_content.class.to_s.demodulize.underscore
    end
  end
end
