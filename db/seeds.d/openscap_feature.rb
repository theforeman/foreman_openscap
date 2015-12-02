f = Feature.find_or_create_by_name('Openscap')
fail "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
