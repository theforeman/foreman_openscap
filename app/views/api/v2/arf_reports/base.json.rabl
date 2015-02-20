object @arf_report

attributes :id, :passed, :failed, :othered
node(:host) { |arf_report| arf_report.host.name }