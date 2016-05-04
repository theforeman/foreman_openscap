object @arf_report

extends "api/v2/compliance/common/org"
extends "api/v2/compliance/common/loc"

attributes :id, :passed, :failed, :othered
node(:host) { |arf_report| arf_report.host.name }
