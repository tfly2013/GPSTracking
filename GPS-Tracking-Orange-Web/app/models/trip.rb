class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :segments
  has_many :locations, :through => :segments
  accepts_nested_attributes_for :segments
end
