require 'rails_helper'

describe "the signin process", :type => :feature do
  before :each do
    User.create(:email => "userkaiqi@test.com", :password => "abc123456",:role => 0)
    User.create(:email => "reseakaiqi@test.com", :password => "abc123456",:role => 1)
    User.create(:email => "adminkaiqi@test.com", :password => "abc123456",:role => 2)
  end

    

    # server_response = post :create , 
    # {  format: :json,
    # :locations =>  [ 
       
    # {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456867 },
    # {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456868 },
    # {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456869 },
    # {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456860 },
    #                ]
    # }, as: :json
    # expect(page).to have_selector '.notice'
    # expect(flash[:notice]).not_to eq("User updated.")
    # expect(flash[:alert]).to eq( "Unable to update user.")
    # flash[:notice].to 
    # find(:flash).to have_content 'Success'
    # expect(page.find('flash')).to have_content 'Post successfully created'
    # expect(page).to have_content 'Success'
    # expect(page).to have_content 'Signed in successfully'

  # it "sign in as user" do
  #   # find('#navigation').click_link('Home')
  #   expect(find('#navigation')).to have_link('GPS Track')
  # end

  it "sign in as user to see trips then sign out" do
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


    it "sign in as researcher to see trips then sign out" do
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'reseakaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    # save_and_open_page
    expect(page).to have_content 'View My Trips'
    find_link('View My Trips').click
    expect(current_path).to eq('/trips')
    expect(page).to have_content 'Trips'
    find_link('Sign out').click
    expect(current_path).to eq('/')
    find_link('Sign In')
  end


    it "sign in as admin to see trips then sign out" do
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'adminkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    # save_and_open_page
    expect(page).to have_content 'Report'
    expect(page).to have_content 'Users'
    expect(page).to have_content 'View My Trips'
    find_link('View My Trips').click
    expect(current_path).to eq('/trips')
    expect(page).to have_content 'Trips'
    find_link('Sign out').click
    expect(current_path).to eq('/')
    find_link('Sign In')
  end


end