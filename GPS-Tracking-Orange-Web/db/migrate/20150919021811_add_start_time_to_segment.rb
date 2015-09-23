class AddStartTimeToSegment < ActiveRecord::Migration
  def change
    add_column :segments, :startTime, :datetime
    add_column :segments, :endTime, :datetime
    add_column :segments, :avgSpeed, :float
    add_column :segments, :highestSpeed, :float
    add_column :segments, :distance, :float
  end
end
