class CreateScaptimonyXccdfRuleResults < ActiveRecord::Migration
  def change
    create_table :scaptimony_xccdf_rule_results do |t|
      t.references :arf_report, index: true, null: false
      t.references :xccdf_result, index: true, null: false
      t.references :xccdf_rule, index: true, null: false
    end
  end
end
