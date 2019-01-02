require 'digest/sha2'
require 'ostruct'

module ForemanOpenscap
  class BulkUpload
    def initialize
      @result = OpenStruct.new(:errors => [], :results => [])
    end

    def files_from_guide
      `rpm -ql scap-security-guide | grep ds.xml`.split
    end

    def scap_guide_installed?
      `rpm -qa | grep scap-security-guide`.present?
    end

    def upload_from_scap_guide
      unless scap_guide_installed?
        @result.errors.push("Can't find scap-security-guide RPM, are you sure it is installed on your server?")
        return @result
      end

      upload_from_files(files_from_guide, true)
    end

    def upload_from_files(files_array, from_scap_guide = false)
      unless files_array.is_a? Array
        @result.errors.push("Expected an array of files to upload, got: #{files_array}.")
        return @result
      end

      files_array.each do |datastream|
        if File.directory?(datastream)
          @result.errors.push("#{datastream} is a directory, expecting file.")
          next
        end

        unless File.file?(datastream)
          @result.errors.push("#{datastream} does not exist, skipping.")
          next
        end

        file = File.open(datastream, 'rb').read
        digest = Digest::SHA2.hexdigest(datastream)
        title = content_name(datastream, from_scap_guide)
        filename = original_filename(datastream)
        scap_content = ScapContent.where(:title => title, :digest => digest).first_or_initialize
        next if scap_content.persisted?
        scap_content.scap_file = file
        scap_content.original_filename = filename
        scap_content.location_ids = Location.all.map(&:id)
        scap_content.organization_ids = Organization.all.map(&:id)

        if scap_content.save
          @result.results.push(scap_content)
        else
          @result.errors.push("Failed saving #{datastream}: #{scap_content.errors.full_messages.uniq.join(',')}")
        end
      end
      @result
    end

    def upload_from_directory(directory_path)
      unless directory_path && Dir.exist?(directory_path)
        @result[:errors].push("No such directory: #{directory_path}. Please check the path you have provided.")
        return @result
      end

      files_array = Dir["#{directory_path}/*-ds.xml"]
      upload_from_files(files_array)
    end

    private

    def extract_name_from_file(file)
      # SCAP datastream files are in format of ssg-<OS>-ds.xml
      # We wish to extract the <OS> and create a name of it
      original_filename(file).gsub('ssg-', '').gsub('-ds.xml', '')
    end

    def original_filename(file)
      file.split('/').last
    end

    def content_name(datastream, from_scap_guide)
      os_name = extract_name_from_file(datastream)
      from_scap_guide ? "Red Hat #{os_name} default content" : "#{os_name} content"
    end
  end
end
