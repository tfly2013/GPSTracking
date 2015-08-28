class Location < ActiveRecord::Base
  belongs_to :user
  belongs_to :segement
  belongs_to :trip
end
