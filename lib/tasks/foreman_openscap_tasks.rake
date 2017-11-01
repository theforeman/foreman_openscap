# Tasks
namespace :foreman_openscap do
  require 'foreman_openscap/bulk_upload'
  require 'foreman_openscap/message_cleaner'

  namespace :bulk_upload do
    desc 'Bulk upload SCAP content from directory'
    task :directory, [:directory] => [:environment] do |task, args|
      abort("# No such directory, please check the path you have provided. #") unless args[:directory].blank? || Dir.exist?(args[:directory])
      User.current = User.anonymous_admin
      ForemanOpenscap::BulkUpload.new.upload_from_directory(args[:directory])
    end

    task :files, [:files] => [:environment] do |task, args|
      files_array = args[:files].split(' ')
      files_array.each do |file|
        abort("# #{file} is a directory, expecting file. Try using 'rake foreman_openscap:bulk_upload:directory' with this directory. #") if File.directory?(file)
      end
      User.current = User.anonymous_admin
      ForemanOpenscap::BulkUpload.new.upload_from_files(files_array)
    end

    task :default => [:environment] do
      User.current = User.anonymous_admin
      ForemanOpenscap::BulkUpload.new(true).generate_scap_default_content
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
end

# Tests
namespace :test do
  desc "Test ForemanOpenscap"
  Rake::TestTask.new(:foreman_openscap) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ["test", test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:foreman_openscap'].invoke
end

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task["jenkins:unit"].enhance do
    Rake::Task['test:foreman_openscap'].invoke
    Rake::Task['foreman_openscap:rubocop'].invoke
  end
end
