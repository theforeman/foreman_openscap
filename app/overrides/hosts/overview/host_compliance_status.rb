Deface::Override.new(:virtual_path => "hosts/show",
                     :name => "add_compliance_link_to_host",
                     :insert_bottom => 'td:last',
                     :partial => 'compliance_hosts/compliance_status')
