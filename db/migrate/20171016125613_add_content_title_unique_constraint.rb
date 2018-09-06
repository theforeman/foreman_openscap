class AddContentTitleUniqueConstraint < ActiveRecord::Migration[4.2]
  def change
    titles = ForemanOpenscap::ScapContent.unscoped.group(:title).count.select { |key, value| value > 1 }.keys
    titles.each do |title|
      duplicates = ForemanOpenscap::ScapContent.unscoped.where :title => title
      say "#{duplicates.count} Scap Contents with duplicate title detected: #{title}"
      duplicates.each.with_index do |item, index|
        next if index == 0
        new_title = item.title + " #{index + 1}"
        say "Renaming Scap Content #{item.title} with id #{item.id} to #{new_title}"
        item.update_attribute(:title, new_title)
      end
    end

    remove_index :foreman_openscap_scap_contents, :name => 'index_scaptimony_scap_contents_on_title' if index_exists?(:foreman_openscap_scap_contents, :title, :name => 'index_scaptimony_scap_contents_on_title')
    add_index :foreman_openscap_scap_contents, :title, :unique => true
  end
end
