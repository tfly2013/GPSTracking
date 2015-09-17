class Segment < ActiveRecord::Base
  belongs_to :trip
  has_many :locations
end
