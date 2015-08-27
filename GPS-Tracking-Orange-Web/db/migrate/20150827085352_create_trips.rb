class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.location :startLocation
      t.location :endLocation
      t.dateTime :startTime
      t.dateTime :endTime
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
