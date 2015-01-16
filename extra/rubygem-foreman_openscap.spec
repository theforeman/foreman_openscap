# This package contains macros that provide functionality relating to
# Software Collections. These macros are not used in default
# Fedora builds, and should not be blindly copied or enabled.
# Specifically, the "scl" macro must not be defined in official Fedora
# builds. For more information, see:
# http://docs.fedoraproject.org/en-US/Fedora_Contributor_Documentation/1/html/Software_Collections_Guide/index.html

%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

%global gem_name foreman_openscap

%global mainver 0.2.0
%global release 1
%{?prever:
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{mainver}%{?prever}
%global gem_docdir %{gem_dir}/doc/%{gem_name}-%{mainver}%{?prever}
%global gem_cache %{gem_dir}/cache/%{gem_name}-%{mainver}%{?prever}.gem
%global gem_spec %{gem_dir}/specifications/%{gem_name}-%{mainver}%{?prever}.gemspec
}

%define rubyabi 1.9.1
%global foreman_dir /usr/share/foreman
%global foreman_bundlerd_dir %{foreman_dir}/bundler.d

Name: %{?scl_prefix}rubygem-%{gem_name}
Version: %{mainver}
Release: 1%{?dist}
Summary: Foreman plug-in for displaying OpenSCAP audit reports
Group: Applications/System
License: GPLv3
URL: https://github.com/OpenSCAP/foreman_openscap
Source0: %{gem_name}-%{version}.gem

Requires: foreman >= 1.5.0

%if 0%{?fedora} > 18
Requires: %{?scl_prefix}ruby(release)
Requires: %{?scl_prefix}ruby(rubygems)
Requires: %{?scl_prefix}rubygem(deface)
Requires: %{?scl_prefix}rubygem(scaptimony) >= 0.2.0
BuildRequires: %{?scl_prefix}ruby(release)
%else
Requires: %{?scl_prefix}ruby(abi) >= %{rubyabi}
Requires: %{?scl_prefix}rubygems
Requires: %{?scl_prefix}rubygem-deface
Requires: %{?scl_prefix}rubygem-scaptimony >= 0.2.0
BuildRequires: %{?scl_prefix}ruby(abi) >= %{rubyabi}
%endif
BuildRequires: %{?scl_prefix}rubygems-devel
BuildRequires: %{?scl_prefix}rubygems
BuildRequires: foreman-assets

BuildArch: noarch
Provides: %{?scl_prefix}rubygem(%{gem_name}) = %{version}
Provides: foreman-plugin-openscap

%description
Foreman plug-in for managing security compliance reports.


%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{?scl_prefix}%{pkg_name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
%{?scl:scl enable %{scl} "}
gem unpack %{SOURCE0}
%{?scl:"}

%setup -q -D -T -n  %{gem_name}-%{version}
mkdir -p .%{gem_dir}
%{?scl:scl enable %{scl} "}
gem install --local --install-dir .%{gem_dir} \
            --force %{SOURCE0} --no-rdoc --no-ri
%{?scl:"}

%build

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{foreman_bundlerd_dir}
cat <<GEMFILE > %{buildroot}%{foreman_bundlerd_dir}/%{gem_name}.rb
gem '%{gem_name}'
gem 'scaptimony'
GEMFILE


# Run the test suite
%check
pushd .%{gem_instdir}

popd

%files
%dir %{gem_instdir}
%{gem_libdir}
%{gem_instdir}/app
%{gem_instdir}/db
%{gem_instdir}/config
%exclude %{gem_cache}
%{gem_spec}
%{foreman_bundlerd_dir}/%{gem_name}.rb
%doc %{gem_instdir}/LICENSE

%exclude %{gem_instdir}/test

%files doc
%doc %{gem_instdir}/LICENSE
%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile

%posttrans
# We need to run the db:migrate (because of SCAPtimony) after the install transaction
/usr/sbin/foreman-rake db:migrate  >/dev/null 2>&1 || :
/usr/sbin/foreman-rake db:seed  >/dev/null 2>&1 || :
/usr/sbin/foreman-rake apipie:cache  >/dev/null 2>&1 || :
(/sbin/service foreman status && /sbin/service foreman restart) >/dev/null 2>&1
exit 0

%changelog
* Thu Dec 04 2014 Šimon Lukašík <slukasik@redhat.com> - 0.2.0-1
- new upstream release

* Thu Oct 23 2014 Šimon Lukašík <slukasik@redhat.com> - 0.1.0-1
- rebuilt

* Mon Jul 28 2014 Šimon Lukašík <slukasik@redhat.com> - 0.0.1-1
- Initial package
