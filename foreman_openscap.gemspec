require File.expand_path('../lib/foreman_openscap/version', __FILE__)

gem_name = "foreman_openscap"

Dir["locale/**/*.po"].each do |po|
  mo = po.sub(/#{gem_name}\.po$/, "LC_MESSAGES/#{gem_name}.mo")
  puts "WARNING: File #{mo} does not exist, generate with 'make all-mo'!" unless File.exist?(mo)
  puts "WARNING: Fie #{mo} outdated, regenerate with 'make all-mo'" if File.mtime(po) > File.mtime(mo)
end

Gem::Specification.new do |s|
  s.name        = "foreman_openscap"
  s.version     = ForemanOpenscap::VERSION
  s.authors     = ["slukasik@redhat.com"]
  s.email       = ["slukasik@redhat.com"]
  s.homepage    = "https://github.com/OpenSCAP/foreman_openscap"
  s.summary     = "Foreman plug-in for displaying OpenSCAP audit reports"
  s.description = "Foreman plug-in for managing security compliance reports"
  s.license     = "GPL-3.0"

  s.files = Dir["{app,config,db,lib,locale}/**/*"] + ["LICENSE", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'deface', '< 2.0'
end
