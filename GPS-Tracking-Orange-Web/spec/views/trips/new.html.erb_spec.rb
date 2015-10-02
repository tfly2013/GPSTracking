# require 'rails_helper'

# RSpec.describe "trips/new", type: :view do
#   before(:each) do
#     assign(:trip, Trip.new(
#       :startLocation => "",
#       :endLocation => "",
#       :startTime => "",
#       :endTime => "",
#       :user => nil
#     ))
#   end

#   it "renders new trip form" do
#     render

#     assert_select "form[action=?][method=?]", trips_path, "post" do

#       assert_select "input#trip_startLocation[name=?]", "trip[startLocation]"

#       assert_select "input#trip_endLocation[name=?]", "trip[endLocation]"

#       assert_select "input#trip_startTime[name=?]", "trip[startTime]"

#       assert_select "input#trip_endTime[name=?]", "trip[endTime]"

#       assert_select "input#trip_user_id[name=?]", "trip[user_id]"
#     end
#   end
# end
