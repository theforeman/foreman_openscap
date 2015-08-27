Deface::Override.new(:virtual_path  => "hosts/_overview",
                     :name          => "add_compliance_check",
                     :insert_after => "#properties_table",
                     :partial       =>  "compliance_hosts/host_status")
