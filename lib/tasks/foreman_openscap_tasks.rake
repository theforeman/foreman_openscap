# Tasks
namespace :foreman_openscap do
  require 'foreman_openscap/bulk_upload'
  require 'foreman_openscap/message_cleaner'

  namespace :bulk_upload do
    desc 'Bulk upload SCAP content from directory'
    task :directory, [:directory] => [:environment] do |task, args|
      deprecate_upload_from_rake
      abort("# No such directory, please check the path you have provided. #") unless args[:directory].blank? || Dir.exist?(args[:directory])
      User.current = User.anonymous_admin
      print_upload_result ForemanOpenscap::BulkUpload.new.upload_from_directory(args[:directory])
    end

    task :files, [:files] => [:environment] do |task, args|
      deprecate_upload_from_rake
      files_array = args[:files].split(' ')
      files_array.each do |file|
        abort("# #{file} is a directory, expecting file. Try using 'rake foreman_openscap:bulk_upload:directory' with this directory. #") if File.directory?(file)
      end
      User.current = User.anonymous_admin
      print_upload_result ForemanOpenscap::BulkUpload.new.upload_from_files(files_array)
    end

    task :default => [:environment] do
      deprecate_upload_from_rake
      User.current = User.anonymous_admin
      print_upload_result ForemanOpenscap::BulkUpload.new.upload_from_scap_guide
    end
  end

  task :migrate, [:proxy] => [:environment] do |task, args|
    require 'foreman_openscap/data_migration'
    puts 'Starting ARF reports migration process...'
    puts "Migrating with proxy id: #{args[:proxy]}"
    abort("Please pass migrating proxy id. run 'rake foreman_openscap:migrate[scap_proxy_id]'") unless args[:proxy]
    migrate = ForemanOpenscap::DataMigration.new(args[:proxy])
    abort("Foreman & proxy should be up for this migration") unless migrate.available?
    migrate.migrate
  end

  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_openscap) do |task|
        task.patterns = ["#{ForemanOpenscap::Engine.root}/app/**/*.rb",
                         "#{ForemanOpenscap::Engine.root}/lib/**/*.rb",
                         "#{ForemanOpenscap::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts 'Rubocop not loaded.'
    end
    Rake::Task['rubocop_foreman_openscap'].invoke
  end

  desc "Clean duplicate messages for ArfReport"
  task :clean_messages => :environment do
    puts 'Searching for duplicated messages and merging them... this can take a long time'
    ForemanOpenscap::MessageCleaner.new.clean
    puts 'Done'
  end

  desc "Delete ArfReports without OpenSCAP proxy"
  task :clean_reports_without_proxy => :environment do
    User.as_anonymous_admin do
      report_ids_without_proxy = ForemanOpenscap::ArfReport.unscoped.where(:openscap_proxy => nil).pluck(:id)
      total = ForemanOpenscap::ArfReport.delete report_ids_without_proxy
      puts "Done cleaning #{total} reports"
    end
  end
end

def deprecate_upload_from_rake
  puts 'DEPRECATION WARNING: Uploading scap contents using rake task is deprecated and will be removed in a future version. Please use API or CLI.'
end

def print_upload_result(result)
  puts result.errors.join(' ') if result.errors.present?
  puts result.results.map { |sc| "Saved #{sc.original_filename} as #{sc.title}" }.join("\n") if result.results.present?
end

# Tests
namespace :test do
  desc "Test ForemanOpenscap"
  Rake::TestTask.new(:foreman_openscap) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ["test", test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :test do
  desc "Test Core parts extended by ForemanOpenscap"
  Rake::TestTask.new(:foreman_openscap_extensions) do |t|
    test_dir = Rails.root.join('test')
    t.libs << ["test", test_dir]
    t.test_files = FileList[
      "#{test_dir}/unit/foreman/access_permissions_test.rb",
      "#{test_dir}/controllers/api/v2/hosts_controller_test.rb",
      "#{test_dir}/controllers/api/v2/hostgroups_controller_test.rb",
      "#{test_dir}/models/hosts/*_test.rb",
      ]
    t.verbose = true
    t.warning = false
  end
end
