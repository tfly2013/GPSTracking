class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.float :latitude
      t.float :longitude
      t.float :accuracy
      t.float :speed
      t.datetime :time
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
