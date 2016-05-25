object @arf_report

extends "api/v2/compliance/arf_reports/base"

attributes :created_at, :updated_at, :host_id, :openscap_proxy_id, :reported_at

node :openscap_proxy_name do |arf|
  arf.openscap_proxy.name
end
