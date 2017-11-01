require 'digest/sha2'

class AddScaptimonyScapContentDigest < ActiveRecord::Migration
  def change
    unless column_exists?(:scaptimony_scap_contents, :digest)
      add_column :scaptimony_scap_contents, :digest, :string, :limit => 128
      ScapContentHack.find_each do |content|
        content.digest
        content.save!
      end
      change_column :scaptimony_scap_contents, :digest, :string, :null => false
    end
  end

  class ScapContentHack < ApplicationRecord
    self.table_name = 'scaptimony_scap_contents'
    def digest
      self[:digest] ||= Digest::SHA256.hexdigest scap_file.to_s
    end
  end
end
