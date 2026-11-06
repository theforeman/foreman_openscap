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

## Installation

- Follow the official guide on [theforeman.org](https://theforeman.org/plugins/foreman_openscap/0.8/index.html#2.Installation)

## SCAP document storage and upgrade

This plugin requires Foreman 5.1 or newer. New SCAP content and tailoring XML files
use Foreman's configured Active Storage service instead of SQL payloads. No
Kubernetes-specific setting is needed. With object storage configured by Foreman,
web and worker processes can read the same documents without sharing a filesystem.
SCAP profiles, policies, digests, taxonomy assignments, XML API responses and their
existing authorization remain unchanged. No public Active Storage download routes
are added. ARF reports and files held by Smart Proxies are not moved by this change.

Existing SQL documents remain readable until migrated. Before migrating, run the
Foreman database migrations, configure and test Foreman's storage service, and
take a database backup. All Foreman processes must use the same storage
configuration and credentials. Local disk storage must be persistent and shared
by any processes that need to read it; this change alone does not make it shared.
Allow temporary disk space for the largest XML document during verification.

From a packaged Foreman installation, preview the copy first:

```console
foreman-rake foreman_openscap:storage:migrate
```

Then copy and verify each document:

```console
APPLY=true foreman-rake foreman_openscap:storage:migrate
```

The task covers all organizations and locations in batches, checks the original
SHA-256 digest, uploads the file, and reads it back before attaching it. It does
not contact Smart Proxies, regenerate profiles or delete SQL data. Re-running it
skips existing attachments. Failures are reported per record and produce a
non-zero exit status; fix the cause and re-run the task. A partially completed
copy remains usable through SQL fallback for the remaining documents.

After checking document downloads and taking a coordinated backup of the database
and attachment store, preview removal of the legacy SQL payloads:

```console
foreman-rake foreman_openscap:storage:cleanup
```

Remove only verified copies by explicitly applying cleanup:

```console
APPLY=true foreman-rake foreman_openscap:storage:cleanup
```

Cleanup reads each attachment and checks it against the record's current digest
before setting its legacy SQL column to NULL. Missing or corrupt objects leave
their SQL source untouched and cause a non-zero exit status. Neither task removes
attachments or unrelated blobs. Both tasks are safe to repeat. Schedule them in
a maintenance window to avoid competing uploads and long row-lock waits.

New uploads and subsequent edits are stored only in Active Storage, so downgrading
to an older plugin or Foreman that only reads SQL requires restoring the matching
pre-upgrade database and storage backup. Retaining SQL during the copy stage is
not a complete downgrade mechanism. Clearing SQL payloads permits PostgreSQL to
reuse space after normal vacuuming; it does not immediately shrink database files
or existing backups.

## Development setup

- set up Foreman for development, preferably using [forklift](https://github.com/theforeman/forklift)
- clone this repo
  ```
    git clone https://github.com/theforeman/foreman_openscap.git
  ```
- point foreman to your checkout
  ```
  echo "gemspec :path => 'path/to/foreman_openscap'" >> foreman/bundler.d/Gemfile.local.rb
  ```
- run bundler, migrations and seeds from foreman dir
  ```
  cd foreman
  bundle install
  rake db:migrate
  rake db:seed
  ```
- start your Rails server, verify openscap plugin is present

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

