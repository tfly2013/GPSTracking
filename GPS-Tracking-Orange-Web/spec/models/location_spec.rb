require 'rails_helper'

RSpec.describe Api::Location, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  # validates :latitude, :inclusion => -90..90, presence: true
  # validates :longitude, :inclusion => -180..180, presence: true
  #   def change
  #   create_table :locations do |t|
  #     t.float :latitude
  #     t.float :longitude
  #     t.float :accuracy
  #     t.datetime :time
  #     t.belongs_to :segment, index: true

  #     t.timestamps null: false
  #   end
  # end
  #   def change
  #   add_column :locations, :speed, :float
  # end
	it "the Location data should be valid" do
		location =Location.new(latitude: 0.1 ,longitude: 0.1 ,accuracy: 5, speed: 10)
		expect(location).to be_valid
	end 
	context " boundary test on-points " do
	it "the Location data should be in the range" do
		location =Location.new(latitude: 90 ,longitude: 180 )
		expect(location).to be_valid
	end 
	it "the Location data should be in the range" do
		location =Location.new(latitude: -90 ,longitude: -180 )
		expect(location).to be_valid
	end 
  end
  	context " boundary test  off-points " do
	it "the Location data should be in the range" do
		location =Location.new(latitude: 90.0000001 ,longitude: 180.0000001 )
		expect(location).not_to be_valid
	end 
	it "the Location data should be in the range" do
		location =Location.new(latitude: -90.0000001 ,longitude: -180.0000001 )
		expect(location).not_to be_valid
	end 
  end
  	it "the latitude should not be missed" do
		location =Location.new(longitude: 0.1 ,accuracy: 5, speed: 10 )
		expect(location).not_to be_valid
	end 
  	it "the longitude should not be missed" do
		location =Location.new(latitude: 0.1 ,accuracy: 5, speed: 10  )
		expect(location).not_to be_valid
	end

end
