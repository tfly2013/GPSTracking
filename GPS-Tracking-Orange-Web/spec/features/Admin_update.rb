require 'rails_helper'

describe "the process of management of users", :type => :feature do
    # the :js => true is to switch the driver to the :selenium ,:js => true 
  before :each do
    User.create(:email => 'userkaiqi@test.com', :password => "abc123456",:role => 0)
    User.create(:email => 'reseakaiqi@test.com', :password => "abc123456",:role => 1)
    User.create(:email => 'adminkaiqi@test.com', :password => "abc123456",:role => 2)
  end


  #   # this will make the new driver work
  #   self.use_transactional_fixtures = false

  #   it "sign in as admin to delete one user then sign out" , :js => true do
  #   visit '/home/index'
  #   find_link('Sign In').click
  #   fill_in 'Email', :with => 'adminkaiqi@test.com'
  #   fill_in 'Password', :with => 'abc123456'
  #   find_button('Sign in').click
  #   # find_link("Users")#new
    
  #   # save_and_open_page
  #   expect(page).to have_content 'Trips'
  #   expect(page).to have_content 'Report'
  #   expect(page).to have_content 'Users'
  #   expect(page).to have_content 'View My Trips'
  #   expect(current_path).to eq('/')

  #   find_link('Users').click

  #   # save_and_open_page

  #   expect(page).to have_selector(:xpath, '//table')

  #   expect(current_path).to eq('/users')

  #   # expect(page.find_all(:select).count).to eq(User.where(role: 0).count)
  #   expect(page.find_all(:button, 'Change Role').count).to eq(User.all.count)

  #   expect(page.find_all(:xpath,'//tr').count).to eq(User.all.count)

  #   old_number = User.all.count

  #   # expect(page.all('//tr').count).to eq(User.all.count)
  #   expect(page.find_all(:link, 'Delete user').count).to eq((User.all.count)-User.where(role: 2).count)#!!!!!!!!!

  #   expect(page.find(:xpath,'//tr[2]/td[3]').text).to eq("Delete user")


  #   # first(:link, 'Delete user').click # this also useful

  #   page.find(:xpath,'//tr[2]/td[3]').click_link('Delete user')



  #   # save_and_open_page

  #   wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
  #   alert = wait.until { page.driver.browser.switch_to.alert }
  #   alert.accept


  #   expect(page).to have_selector(:xpath, '//table')

  #   expect(page.find_all(:xpath,'//tr').count).to eq(User.all.count)

  #   expect(User.all.count).to eq(old_number-1)

  #   # save_and_open_page

  #   find_link('Sign out').click
  #   # expect(current_path).to eq('/')
  #   # find_link('Sign In')
  # end



    # this will make the new driver work
    self.use_transactional_fixtures = false

    it "sign in as admin to update one user then sign out" , :js => true do
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'adminkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    # find_link("Users")#new
    
    # save_and_open_page
    expect(page).to have_content 'Trips'
    expect(page).to have_content 'Report'
    expect(page).to have_content 'Users'
    expect(page).to have_content 'View My Trips'
    expect(current_path).to eq('/')

    find_link('Users').click

    # save_and_open_page

    expect(page).to have_selector(:xpath, '//table')

    expect(current_path).to eq('/users')

    # expect(page.find_all(:select).count).to eq(User.where(role: 0).count)
    expect(page.find_all(:button, 'Change Role').count).to eq(User.all.count)

    expect(page.find_all(:xpath,'//tr').count).to eq(User.all.count)

    old_number = User.all.count

    # expect(page.all('//tr').count).to eq(User.all.count)
    expect(page.find_all(:link, 'Delete user').count).to eq((User.all.count)-User.where(role: 2).count)#!!!!!!!!!

    expect(page.find(:xpath,'//tr[2]/td[3]').text).to eq("Delete user")


    # first(:link, 'Delete user').click # this also useful
    
    # page.find(:xpath,'//tr[2]/td[3]').click_link('Delete user')

    # page.find(:xpath,'//tr[2]/td[2]').click_link('Delete user')

    # page.find(:xpath,'//tr[2]/td[2]').find(:select).find(:xpath, 'option[3]').select_option

    expect(page.find_all(:xpath,'//select').count).to eq(User.all.count)

    email_add = page.find(:xpath,'//tr[2]/td[1]').text

    # page.find(:xpath,'//tr[2]/td[2]').find(:xpath,'/select').find(:xpath, 'option[3]').select_option
    page.find(:xpath,'//tr[2]/td[2]//select').find(:xpath, "option[3]").select_option

    # page.find(:xpath,'//tr[2]/td[2]//submit').click

    page.find(:xpath,'//tr[2]/td[2]').click_button('Change Role')

    save_and_open_page

    expect(User.where(email: email_add).first[:role]).to eq(2) 
    # the third option is Admin while the role [2] is Admin

    # wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
    # alert = wait.until { page.driver.browser.switch_to.alert }
    # alert.accept


    expect(page).to have_selector(:xpath, '//table')

    expect(page.find_all(:xpath,'//tr').count).to eq(User.all.count)

    # expect(User.all.count).to eq(old_number-1)

    # save_and_open_page

    find_link('Sign out').click
    # expect(current_path).to eq('/')
    # find_link('Sign In')
  end


end