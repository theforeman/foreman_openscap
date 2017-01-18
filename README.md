# Foreman-OpenSCAP

[![Code Climate](https://codeclimate.com/github/OpenSCAP/foreman_openscap/badges/gpa.svg)](https://codeclimate.com/github/OpenSCAP/foreman_openscap)

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

The most of the Foreman-OpenSCAP controls are located in the *Compliance* section under the *Host*
menu. The section contains three items as described in previous section: SCAP Contents, Compliance
Policies, ARF Reports.

### Prerequisites before the first use

Make sure that
1. smart_proxy_openscap and puppet-foreman_scap_client packages are installed on your proxies
2. proxies have Foreman uri defined
  ```
  # echo ':foreman_url: https://foreman17.local.lan' >> /etc/foreman-proxy/settings.yml
  ```
3. foreman_scap_client puppet class is imported to your Foreman
  1. Go to Configure -> Puppet classes page
  2. Click Import button
  3. Select foreman_scap_client

### Setting-up first compliance policy

1. Log-in to Web Interface
2. Create new SCAP Content
  1. Go to *Hosts -> Compliance -> SCAP contents* page
  2. Upload DataSteam file
3. Create new Policy
  1. Go to Hosts -> Compliance -> Policies page
  2. Assign SCAP Content to Policy
  3. Select Profile from your SCAP Content
  4. Define periodic scan schedule
  5. Assign Hostgroups to the policy (hosts you want to audit should be assigned with one of the
     hostgroups)
4. Select particular hosts for compliance audit
  1. Go to *Hosts -> All hosts* page
  2. Select hosts
  3. Use *Select Action -> Assign Compliance Policy* button
5. Make sure the DataStream file is present on the clients' file system.

   At the moment, Foreman infrastructure is not able to serve a file to the clients. Hence, users
   are required to distribute their DataStrem file to each client. The expected location is
   defined at *Compliance Policy -> Edit* dialogue.
6. Inspect the compliance results
  1. Go to *Hosts -> Compliance -> Reports* page
  2. Wait for ARF Reports to show-up
  3. Go to *Hosts -> Compliance -> Policies* page
  4. Click the policy link to view dashboard and trend

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

## Releasing

follow these steps:

1. Bump the version.rb to desired number
2. git commit -a -m "Version $number"
3. rake release

the commit gets tagged with what it find in version.rb

if you have commit permissions, the commit and the tag gets pushed to origin remote

if you're the gem owner, gem is built and uploaded to rubygems.org

## Found a bug?

We use the issue tracker at [http://projects.theforeman.org/projects/foreman_openscap/issues](http://projects.theforeman.org/projects/foreman_openscap/issues), it supports github SSO so it's straightforward to open new issues there. If you think you found a bug, please take search through existing issues and if you haven't found any, free free to open a new one. Thank you.

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

