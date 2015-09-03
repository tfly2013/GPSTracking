class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.float :latitude
      t.float :longitude
      t.float :accuracy
      t.datetime :time
      t.belongs_to :segment, index: true

      t.timestamps null: false
    end
  end
end
