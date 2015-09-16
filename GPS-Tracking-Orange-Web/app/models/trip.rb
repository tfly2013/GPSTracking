class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :segments
  has_many :locations, :through => :segments
end
