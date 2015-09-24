class ChangeLocation < ActiveRecord::Migration
  def change
  	add_column :locations, :order, :integer
  end
end
