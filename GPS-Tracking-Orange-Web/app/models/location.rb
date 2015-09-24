class Location < ActiveRecord::Base
  belongs_to :segment
  validates :latitude, :inclusion => -90..90, presence: true
  validates :longitude, :inclusion => -180..180, presence: true
end
