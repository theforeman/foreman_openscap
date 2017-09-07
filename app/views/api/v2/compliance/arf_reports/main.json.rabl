object @arf_report

extends "api/v2/compliance/arf_reports/base"

attributes :created_at, :updated_at, :reported_at

child :openscap_proxy => :openscap_proxy do
  attributes :id, :name
end

child :host do
  attributes :id, :name
end

child :policy do
  attributes :id, :name
end
