require 'rails_helper'

describe "the signin process", :type => :feature do
  before :each do
    User.create(:email => "userkaiqi@test.com", :password => "abc123456",:role => 0)
    User.create(:email => "reseakaiqi@test.com", :password => "abc123456",:role => 1)
    User.create(:email => "adminkaiqi@test.com", :password => "abc123456",:role => 2)
  end


  # end
  it "sign up as user to see trips then sign out" do
    old_number = User.all.count

    visit '/home/index'
    find_link('Sign Up').click
    fill_in 'Email', :with => 'newuserkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    fill_in 'Password confirmation', :with => 'abc123456'
    find_button('Sign up').click
    expect(current_path).to eq('/')
    expect(page).to have_content 'View My Trips'
    # find_link('View My Trips').click
    # expect(current_path).to eq('/trips')
    # expect(page).to have_content 'Trips'
    find_link('Sign out').click
    expect(current_path).to eq('/')
    find_link('Sign In')

    expect(User.all.count).to eq(old_number+1)

    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'userkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    expect(page).to have_content 'View My Trips'
    find_link('View My Trips').click
    expect(current_path).to eq('/trips')
    expect(page).to have_content 'Trips'
    find_link('Sign out').click
    expect(current_path).to eq('/')
    find_link('Sign In')
  end
end
