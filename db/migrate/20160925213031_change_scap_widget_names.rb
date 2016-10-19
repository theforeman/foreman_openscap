class ChangeScapWidgetNames < ActiveRecord::Migration
  def up
    Widget.where(:name => 'OpenSCAP Host reports widget').\
      update_all(:name => 'Latest Compliance Reports')
    Widget.where(:name => 'OpenSCAP Reports breakdown widget').\
      update_all(:name => 'Compliance Reports Breakdown')
  end

  def down
    Widget.where(:name => 'Latest Compliance Reports').\
      update_all(:name => 'OpenSCAP Host reports widget')
    Widget.where(:name => 'Compliance Reports Breakdown').\
      update_all(:name => 'OpenSCAP Reports breakdown widget')
  end
end
