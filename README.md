# Foreman-OpenSCAP

This plug-in enables automated vulnerability assessment and compliance audit
of Foreman based infrastructure.

+ Current features:
  + Centralized policy management
  + Set-up organization defined targeting (connect set of system, a policy and time schedule)
  + Set-up periodical audits
  + Search for not audited systems
  + Collect & achieve OpenSCAP audit results from your infrastructure
  + Display audit results
  + Search audit results
  + Search for non-compliant systems
+ Future features:
  + Comparison of audit results
  + Waive known issues (one-time waivers, re-occurring, waivers)
  + Ad-hoc audit of given machine
  + Support for PreupgradeAssistant evaluation
  + Vulnerability Assessment (processing OVAL CVE streams)
  + E-mail notifications

## Usage

### Basic Concepts

There are three basic concepts (entities) in OpenSCAP plug-in: SCAP Contents, Compliance
Policies and ARF Reports.

*SCAP Content* represents SCAP DataStream XML file as defined by SCAP 1.2 standard. Datastream
file contains implementation of compliance, configuration or security baselines. Users are
advised to acquire examplary baseline by installing scap-security-guide package. DataStream
file usualy contains multiple XCCDF Profiles. Each for different security target. The content
of Datastream file can be inspected by `oscap` tool from openscap-scanner package.

  ```
  # yum install -y scap-security-guide openscap-scanner
  # oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
  # oscap info /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml
  ```

*Compliance Policy* is highlevel concept of a baseline applied to the infrastructure. Compliance
Policy is defined by user on web interface. User may assign following information to the Policy:
+ SCAP Content
+ XCCDF Profile from particular SCAP Content
+ Host Groups that should comply with the policy
+ Schedule - the period in which the audit shall occur

*ARF Report* is XML output of single scan occurance per single host. Asset Reporting File format
is defined by SCAP 1.2 standard. Foreman plug-in stores the ARF Reports in database for later
inspections.

### User Interface

There is section called *Compliance* under the *Host* menu. The section cotains three items as
described in previous section: SCAP Contents, Compliance Policies, ARF Reports.

## Installation from RPMS

- Install Foreman from [upstream](http://theforeman.org/)

- Install foreman-proxy_openscap to all your foreman-proxies from [upstream](https://github.com/OpenSCAP/foreman-proxy_openscap)

- Enable [isimluk/OpenSCAP](https://copr.fedoraproject.org/coprs/isimluk/OpenSCAP/) COPR repository

- Install Foreman_OpenSCAP

  ```
  yum install rubygem-foreman_openscap ruby193-rubygem-foreman_openscap
  ```

## Installation from upstream git

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
  # yum install yum-utils rpm-build scl-utils scl-utils-build ruby193-rubygems-devel ruby193-build ruby193
  # yum-builddep extra/rubygem-foreman_openscap.spec
  $ rpmbuild  --define "_sourcedir `pwd`" --define "scl ruby193" -ba extra/rubygem-foreman_openscap.spec
  ```

- Install foreman_openscap RPM

  ```
  # yum localinstall ~/rpmbuild/RPMS/noarch/ruby193-rubygem-foreman_openscap-*.noarch.rpm
  # service foreman restart
  ```

## Copyright

Copyright (c) 2014--2015 Red Hat, Inc.

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

