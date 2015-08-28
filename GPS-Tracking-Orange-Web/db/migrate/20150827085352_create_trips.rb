class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.integer :startLocation
      t.integer :endLocation
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
