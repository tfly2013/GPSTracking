require 'rails_helper'

describe "the process of management of users", :type => :feature do
    # the :js => true is to switch the driver to the :selenium ,:js => true 
  before :each do
    User.create(:email => 'userkaiqi@test.com', :password => "abc123456",:role => 0)
    User.create(:email => 'reseakaiqi@test.com', :password => "abc123456",:role => 1)
    User.create(:email => 'adminkaiqi@test.com', :password => "abc123456",:role => 2)
  end

    it "sign in as admin to see trips then sign out" do
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'adminkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    # save_and_open_page
    expect(page).to have_content 'Trips'
    expect(page).to have_content 'Report'
    expect(page).to have_content 'Users'
    expect(page).to have_content 'View My Trips'
    find_link('View My Trips').click
    save_and_open_page
    expect(current_path).to eq('/trips')
    expect(page).to have_content 'Trips'
    find_link('Sign out').click
    expect(current_path).to eq('/')
    find_link('Sign In')
  end

    it "sign in as admin to see reports then sign out" do
    pending("will raise ZeroDivisionError")
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'adminkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    # save_and_open_page
    expect(page).to have_content 'Trips'
    expect(page).to have_content 'Report'
    expect(page).to have_content 'Users'
    expect(page).to have_content 'View My Trips'
    find_link('Report').click
    expect(current_path).to eq('/reports')
    expect(page).to have_content 'Statistics:'
    save_and_open_page
  end
    it "sign in as admin to see users then sign out" do
    visit '/home/index'
    find_link('Sign In').click
    fill_in 'Email', :with => 'adminkaiqi@test.com'
    fill_in 'Password', :with => 'abc123456'
    find_button('Sign in').click
    expect(current_path).to eq('/')
    # save_and_open_page
    expect(page).to have_content 'Trips'
    expect(page).to have_content 'Report'
    expect(page).to have_content 'Users'
    expect(page).to have_content 'View My Trips'
    find_link('Users').click
    expect(current_path).to eq('/users')
    save_and_open_page
    expect(page).to have_content 'Users'
    find_link('Sign out').click
    expect(current_path).to eq('/')
    find_link('Sign In')
  end


    # this will make the new driver work
    self.use_transactional_fixtures = false

    it "sign in as admin to delete one user then sign out" , :js => true do
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
    # expect(find('//tr[1]/td[3]')).to eq("Delete user")
    # end
    # page.accept_alert 'Are ' do
    # click_button('Search')
    # end
    # find('//tr[1]/td[3]').click
    # save_and_open_screenshot
    # page.evaluate_script('window.confirm = function() { return true; }')

    # page.find(:xpath,'//tr[2]/td[3]').click_link('Delete user') # also useful

    first(:link, 'Delete user').click

    # save_and_open_page

    # Capybara.current_driver = :selenium # temporarily select different driver
    # tests here
    # page.evaluate_script('window.confirm = function() { return true; }')
    # find_link("Delete user").click
    # page.driver.navigate.refresh

    # page.driver.browser.switch_to.alert.accept
    wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
    alert = wait.until { page.driver.browser.switch_to.alert }
    alert.accept


    # driver.switchTo().frame(0);
    # page.driver.browser.switchTo().frame(0);

    # Capybara.use_default_driver       # switch back to default driver

    # page.driver.browser.switch_to_window.alert.accept

    # save_and_open_page

    # expect(page.find_all(:table).count).to eq(User.where(role: 0).count)
    # expect(find_all(:text =>"Change Role").count).to eq(User.all.count)
    # page.driver.navigate.refresh

    expect(page).to have_selector(:xpath, '//table')

    expect(page.find_all(:xpath,'//tr').count).to eq(User.all.count)

    expect(User.all.count).to eq(old_number-1)

    save_and_open_page

    find_link('Sign out').click
    # expect(current_path).to eq('/')
    # find_link('Sign In')
  end



end