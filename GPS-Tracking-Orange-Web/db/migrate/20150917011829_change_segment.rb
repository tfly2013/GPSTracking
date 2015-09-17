class ChangeSegment < ActiveRecord::Migration
	def change
		remove_column :segments, :startLocation, :integer
		remove_column :segments, :endLocation, :integer
		add_column :segments, :order, :integer
	end
end
