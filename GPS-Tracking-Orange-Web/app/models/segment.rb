class Segment < ActiveRecord::Base
  belongs_to :trip
  has_many :locations
  accepts_nested_attributes_for :locations
end
