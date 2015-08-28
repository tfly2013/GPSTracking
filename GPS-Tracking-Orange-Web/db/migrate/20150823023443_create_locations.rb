class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.float :latitude
      t.float :longitude
      t.float :accuracy
      t.float :speed
      t.datetime :time
      t.belongs_to :user, index: true
      t.belongs_to :segment, index: true
      t.belongs_to :trip, index: true

      t.timestamps null: false
    end
  end
end
