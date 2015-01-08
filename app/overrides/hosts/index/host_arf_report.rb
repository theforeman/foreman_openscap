Deface::Override.new(:virtual_path  => "hosts/_list",
                     :name          => "add_comliance_header",
                     :insert_before => "th:last",
                     :text          =>  "<th>#{_('Compliance')}</th>")

Deface::Override.new(:virtual_path  => "hosts/_list",
                     :name          => "add_compliance_host_data",
                     :insert_before => "td:last",
                     :partial       =>  "scaptimony_arf_reports/host_report")
