require 'digest/sha2'
module ForemanOpenscap
  class BulkUpload
    attr_accessor :from_scap_security_guide
    def initialize(from_scap_security_guide=false)
      @from_scap_security_guide = from_scap_security_guide
    end

    def generate_scap_default_content
      return unless @from_scap_security_guide

      if `rpm -qa | grep scap-security-guide`.empty?
        Rails.logger.debug "Can't find scap-security-guide RPM"
        return
      end

      files_array = `rpm -ql scap-security-guide | grep ds.xml`.split
      upload_from_files(files_array) unless files_array.empty?
    end

    def upload_from_files(files_array)
      files_array.each do |datastream|
        file = File.open(datastream, 'rb').read
        digest = Digest::SHA2.hexdigest(datastream)
        title = content_name(datastream)
        filename = original_filename(datastream)
        scap_content = Scaptimony::ScapContent.where(:title => title, :digest => digest, :scap_file => file).first_or_initialize
        unless scap_content.persisted?
          scap_content.original_filename = filename
          next puts "## SCAP content is invalid: #{scap_content.errors.full_messages.uniq.join(',')} ##" unless scap_content.valid?
          if scap_content.save
            puts "Saved #{datastream} as #{scap_content.title}"
          else
            puts "Failed saving #{datastream}"
          end
        end
      end
    end

    def upload_from_directory(directory_path)
      files_array = Dir["#{directory_path}/*-ds.xml"]
      upload_from_files(files_array) unless files_array.empty?
    end

    private

    def extract_name_from_file(file)
      # SCAP datastream files are in format of ssg-<OS>-ds.xml
      # We wish to extract the <OS> and create a name of it
      original_filename(file).gsub('ssg-','').gsub('-ds.xml', '')
    end

    def original_filename(file)
      file.split('/').last
    end

    def content_name(datastream)
      os_name = extract_name_from_file(datastream)
      @from_scap_security_guide ? "Red Hat #{os_name} default content" : "#{os_name} content"
    end
  end
end
