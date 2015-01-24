
Deface::Override.new(:virtual_path  => "hosts/_list",
                     :name          => "add_compliance_host_data",
                     :surround_contents => "td[@class='ellipsis']",
                     :partial       =>  "scaptimony_arf_reports/host_report")
