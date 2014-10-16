# Foreman-OpenSCAP

This plug-in enables automated vulnerability assessment and compliance audit
of Foreman based infrastructure.

+ Current features:
  + Collect & achieve OpenSCAP audit results from your infrastructure
+ Future features:
  + Display audit results
  + Set-up organization defined targeting (connect set of system, a policy and time schedule)
  + Set-up periodical audits
  + Search audit results
  + Search for non-compliant systems
  + Search for not audited systems
  + Comparison of audit results
  + Waive known issues (one-time waivers, re-occurring, waivers)
  + Ad-hoc audit of given machine

## Installation

- Install Foreman from [upstream](http://theforeman.org/)
- Install SCAPtimony from [upstream](https://github.com/OpenSCAP/scaptimony)
- Install foreman-proxy_openscap to all your foreman-proxies from [upstream](https://github.com/OpenSCAP/foreman-proxy_openscap)
- Get foreman_openscap sources

  ```
  $ git clone https://github.com/OpenSCAP/foreman_openscap.git
  ```

- Build foreman_openscap RPM (instructions for Red Hat Enterprise Linux 6)

  ```
  $ cd foreman_openscap
  $ gem build foreman_openscap.gemspec
  # yum install yum-utils rpm-build scl-utils scl-utils-build ruby193-rubygems-devel
  # yum-builddep extra/rubygem-foreman_openscap.spec
  # rpmbuild  --define "_sourcedir `pwd`" --define "scl ruby193" -ba extra/rubygem-foreman_openscap.spec
  ```

- Install foreman_openscap RPM

  ```
  $ yum local install ~/rpmbuild/RPMS/noarch/ruby193-rubygem-foreman_openscap-*.noarch.rpm
  # service foreman restart
  ```

## Usage

Deploy openscap::xccdf::foreman_audit puppet class from Foreman on your clients.
The client will schedule OpenSCAP audit as requested by the Puppet class. The audit
report will be then transfered from the client machine to the proxy (foreman-proxy_openscap).
Then audit reports are forwarded from proxy to SCAPtimony in batches and achieved at
your Foreman server.

More coming, see future features above.

## Copyright

Copyright (c) 2014 Red Hat, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

