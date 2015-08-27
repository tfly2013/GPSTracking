class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.location :startLocation
      t.location :endLocation
      t.dateTime :startTime
      t.dateTime :endTime
      t.string :transportation
      t.references :trip, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
