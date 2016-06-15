require File.expand_path('../lib/foreman_openscap/version', __FILE__)

GEM_NAME = "foreman_openscap"

Dir["locale/**/*.po"].each do |po|
  mo = po.sub(/#{GEM_NAME}\.po$/, "LC_MESSAGES/#{GEM_NAME}.mo")
  puts "WARNING: File #{mo} does not exist, generate with 'make all-mo'!" unless File.exist?(mo)
  puts "WARNING: Fie #{mo} outdated, regenerate with 'make all-mo'" if File.mtime(po) > File.mtime(mo)
end

Gem::Specification.new do |s|
  s.name        = "foreman_openscap"
  s.version     = ForemanOpenscap::VERSION
  s.authors     = IO.readlines("CONTRIBUTORS").map(&:strip)
  s.email       = ["slukasik@redhat.com"]
  s.homepage    = "https://github.com/OpenSCAP/foreman_openscap"
  s.summary     = "Foreman plug-in for displaying OpenSCAP audit reports"
  s.description = "Foreman plug-in for managing security compliance reports"
  s.license     = "GPL-3.0"

  s.files = Dir["{app,config,db,lib,locale}/**/*"] + ["LICENSE", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'deface', '< 2.0'
end
