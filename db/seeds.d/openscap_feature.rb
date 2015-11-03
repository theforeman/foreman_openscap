f = Feature.where(:name => 'Openscap').first_or_create
fail "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
