# Generated from foreman_openscap-0.0.1.gem by gem2rpm -*- rpm-spec -*-
%global gem_name foreman_openscap

%global foreman_dir /usr/share/foreman
%global foreman_bundlerd_dir %{foreman_dir}/bundler.d

Name: rubygem-%{gem_name}
Version: 0.0.1
Release: 1%{?dist}
Summary: Foreman plug-in for displaying OpenSCAP audit reports
Group: Applications/System
License: GPLv3
URL: https://github.com/OpenSCAP/foreman_openscap
Source0: %{gem_name}-%{version}.gem
Requires: ruby(release)
Requires: ruby(rubygems)
Requires: rubygem(deface)
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
BuildArch: noarch
Provides: rubygem(%{gem_name}) = %{version}

%description
Foreman plug-in for managing security compliance reports.


%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
gem unpack %{SOURCE0}

%setup -q -D -T -n  %{gem_name}-%{version}

gem spec %{SOURCE0} -l --ruby > %{gem_name}.gemspec

%build
# Create the gem as gem install only works on a gem file
gem build %{gem_name}.gemspec

# %%gem_install compiles any C extensions and installs the gem into ./%%gem_dir
# by default, so that we can move it into the buildroot in %%install
%gem_install

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{foreman_bundlerd_dir}
cat <<GEMFILE > %{buildroot}%{foreman_bundlerd_dir}/%{gem_name}.rb
gem '%{gem_name}'
GEMFILE


# Run the test suite
%check
pushd .%{gem_instdir}

popd

%files
%dir %{gem_instdir}
%{gem_libdir}
%{gem_instdir}/app
%{gem_instdir}/config
%exclude %{gem_cache}
%{gem_spec}
%{foreman_bundlerd_dir}/%{gem_name}.rb
%doc %{gem_instdir}/LICENSE

%exclude %{gem_instdir}/test

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/LICENSE
%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile


%changelog
* Mon Jul 28 2014 Šimon Lukašík <slukasik@redhat.com> - 0.0.1-1
- Initial package
