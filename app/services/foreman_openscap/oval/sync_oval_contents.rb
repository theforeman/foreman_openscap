module ForemanOpenscap
  module Oval
    class SyncOvalContents
      def sync
        to_sync = ForemanOpenscap::OvalContent.where.not(:url => nil)
        to_sync.map do |content|
          begin
            content_blob = fetch_content_blob(content.url)
          rescue StandardError => e
            content.errors.add(:base, e.message)
            next content
          end

          unless content_blob
            content.errors.add(:base, "Failed to fetch content file from #{content.url}")
            next content
          end
          content.tap do |record|
            record.scap_file = content_blob
            record.save
          end
        end
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
