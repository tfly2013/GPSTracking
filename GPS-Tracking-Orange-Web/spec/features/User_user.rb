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

    # this will make the new driver work
    # self.use_transactional_fixtures = false, :js => true
  it "sign in as user to change password then sign out"  do#////////////////////not good
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'userkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    # click the profile 
    find_link('Profile').click
    # jump to self page
    find_link('Change Password')
    expect(current_path).to have_content('/users/')#////////////
    expect(page).to have_content 'Email:'
    expect(page).to have_content 'userkaiqi@test.com'
    find_link('Change Password').click
    # expect(current_path).to eq('/users/5')#!!!!!!!!!!!!!!!!!
   
    # jump to edit page change the password
    find_button('Update')
    expect(current_path).to eq('/users/edit')

    fill_in 'Password', :with => 'abcdefghi'
    fill_in 'Password confirmation', :with => 'abcdefghi'
    fill_in 'Current password', :with => 'abc123456'
    find_button('Update').click
    
    expect(current_path).to eq('/')
    

    # sign out
    find_link('Sign out').click
    expect(current_path).to eq('/')
    find_link('Sign In')

    # sign in again using new password
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'userkaiqi@test.com'
    fill_in 'Password', :with => 'abcdefghi'
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

  #   it "sign in as user to see reports then sign out" do
  #   pending("user should be able to see their own reports")
  #   visit '/home/index'
  #   find_link('Sign In').click
  #   fill_in 'Email', :with => 'userkaiqi@test.com'
  #   fill_in 'Password', :with => 'abc123456'
  #   find_button('Sign in').click
  #   expect(current_path).to eq('/')
  #   # save_and_open_page
  #   expect(page).to have_content 'Trips'
  #   expect(page).to have_content 'Report'
  #   expect(page).to have_content 'Users'
  #   expect(page).to have_content 'View My Trips'
  #   find_link('Report').click
  #   expect(current_path).to eq('/reports')
  #   expect(page).to have_content 'Statistics:'
  #   save_and_open_page
  # end
    it "sign in as user to see user reports then sign out" do
    # pending("will raise ZeroDivisionError")
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'userkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    # save_and_open_page
    expect(page).to have_content 'Trips'
    expect(page).to have_content 'Report'
    expect(page).to have_content 'View My Trips'
    save_and_open_page

    find_link('Report').click

    
    find_link('Report')
    expect(current_path).to eq('/user_report')
    expect(page).to have_content 'Statistics:'
    expect(page).not_to have_link 'User Report'
    expect(page).not_to have_link 'Overall Report'

  end



end