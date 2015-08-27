require 'rails_helper'

RSpec.describe "trips/index", type: :view do
  before(:each) do
    assign(:trips, [
      Trip.create!(
        :startLocation => "",
        :endLocation => "",
        :startTime => "",
        :endTime => "",
        :user => nil
      ),
      Trip.create!(
        :startLocation => "",
        :endLocation => "",
        :startTime => "",
        :endTime => "",
        :user => nil
      )
    ])
  end

  it "renders a list of trips" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
