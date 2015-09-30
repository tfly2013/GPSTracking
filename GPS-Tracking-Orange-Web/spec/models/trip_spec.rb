require 'rails_helper'

RSpec.describe Trip, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

# class CreateTrips < ActiveRecord::Migration
#   def change
#     create_table :trips do |t|
# 		add_column :trips, :validated, :boolean
#       t.belongs_to :user, index: true
#       t.timestamps null: false
#     end
#   end
# end
	it "the trip data should be valid when validated = true" do
		trip =Trip.new(validated: true)
		expect(trip).to be_valid
	end 
	it "the trip data should be valid when validated = false" do
		trip =Trip.new(validated: false)
		expect(trip).to be_valid
	end 
	it "the trip data should be valid when validated is not given" do
		trip =Trip.new()
		expect(trip).to be_valid
	end 
	

end
