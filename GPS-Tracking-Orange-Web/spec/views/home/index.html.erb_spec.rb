require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  # before(:each) do
  #   @report = assign(:report, Report.create!())
  # end

  it "renders the home page" do
    render
    expect(rendered).to include("GPS Track")
    expect(rendered).to include("Sign in")
    expect(rendered).to include("Sign up")
    expect(rendered).to have_link('Sign In', href: new_user_session_path)
    expect(rendered).to have_link('Sign Up', href: new_user_registration_path)
    # expect(rendered).to have_selector('Sign Up', href: new_user_registration_path)
    # expect(rendered) have_button("Sign In")
  end
end


# spec/views/products/show.html.erb_spec.rb
# require 'spec_helper'
# describe 'products/show.html.erb' do
#   it 'displays product details correctly' do
#     assign(:product, Product.create(name: 'Shirt', price: 50.0))
# render
# rendered.should contain('Shirt')
#     rendered.should contain('50.0')
#   end
# end

# RSpec.describe "events/show", :type => :view do
#   it "displays the event location" do
#     assign(:event, Event.new(:location => "Chicago"))
#     render
#     expect(rendered).to include("Chicago")
#   end
# end
