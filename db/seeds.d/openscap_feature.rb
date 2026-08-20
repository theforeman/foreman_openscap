f = Feature.where(:name => 'Openscap').first_or_create
raise "Unable to create proxy feature: #{SeedHelper.format_errors(f)}" if f.nil? || f.errors.any?
