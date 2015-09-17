class ChangeTrip < ActiveRecord::Migration
	def change
		remove_column :trips, :startLocation, :integer
		remove_column :trips, :endLocation, :integer
		add_column :trips, :validated, :boolean
	end
end
