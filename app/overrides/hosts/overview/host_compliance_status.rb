Deface::Override.new(:virtual_path  => "hosts/_overview",
                     :name          => "add_compliance_check",
                     :insert_after => "#properties_table",
                     :partial       =>  "scaptimony_hosts/host_status")