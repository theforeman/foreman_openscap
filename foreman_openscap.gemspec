require File.expand_path('../lib/foreman_openscap/version', __FILE__)

gem_name = "foreman_openscap"

Dir["locale/**/*.po"].each do |po|
  mo = po.sub(/#{gem_name}\.po$/, "LC_MESSAGES/#{gem_name}.mo")
  STDERR.puts "WARNING: File #{mo} does not exist, generate with 'make all-mo'!" unless File.exist?(mo)
  STDERR.puts "WARNING: File #{mo} outdated, regenerate with 'make all-mo'" if File.mtime(po) > File.mtime(mo)
end

Gem::Specification.new do |s|
  s.name        = "foreman_openscap"
  s.version     = ForemanOpenscap::VERSION
  s.authors     = ["slukasik@redhat.com"]
  s.email       = ["slukasik@redhat.com"]
  s.homepage    = "https://github.com/theforeman/foreman_openscap"
  s.summary     = "Foreman plug-in for displaying OpenSCAP audit reports"
  s.description = "Foreman plug-in for managing security compliance reports"
  s.license     = "GPL-3.0"

  s.files = Dir["{app,config,db,lib,locale,webpack}/**/*"] + ["LICENSE", "README.md", "package.json"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rake"
end
