module ForemanOpenscap
  module Oval
    class SyncOvalContents
      def sync(oval_content)
        begin
          content_blob = fetch_content_blob(oval_content.url)
        rescue StandardError => e
          oval_content.errors.add(:base, "#{fail_msg oval_content}, cause: #{e.message}")
          return oval_content
        end

        unless content_blob
          oval_content.errors.add(:base, fail_msg(oval_content))
          return oval_content
        end
        oval_content.scap_file = content_blob
        oval_content
      end

      def sync_all
        to_sync = ForemanOpenscap::OvalContent.where.not(:url => nil)
        to_sync.map { |content| content.tap { |item| sync(item).save } }
      end

      private

      def fail_msg(content)
        "Failed to fetch content file from #{content.url}"
      end

      def fetch_content_blob(url)
        response = fetch url
        return unless response.code == 200
        response.body
      end

      def fetch(url)
        RestClient.get(url)
      end
    end
  end
end
