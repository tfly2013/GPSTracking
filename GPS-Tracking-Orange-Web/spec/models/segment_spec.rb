require 'rails_helper'

RSpec.describe Segment, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  	it "the segment data should be valid when transportation = walking " do
		segment =Segment.new(transportation: "walking")
		expect(segment).to be_valid
	end 
	it "the segment data should be valid when transportation = otherstring " do
		segment =Segment.new(transportation: "otherstring")
		expect(segment).to be_valid
	end 
	it "the segment data should be valid when transportation is not given" do
		segment =Segment.new()
		expect(segment).to be_valid
	end 
end
