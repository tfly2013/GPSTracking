class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.integer :startLocation
      t.integer :endLocation
      t.string :transportation
      t.belongs_to :trip, index: true

      t.timestamps null: false
    end
  end
end
