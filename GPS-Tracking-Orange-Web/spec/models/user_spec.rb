require 'rails_helper'

describe "User" do
	it "is invalid without password" do
		user = User.new    
		user.email = "Jack@163.com"
		user.password = ""
		user.valid?
		expect(user.errors[:password]).to include("can't be blank")
	end
	it "is invalid without email" do
		user = User.new    
		user.email = ""
		user.password = "JackJackJack"
		user.valid?
		expect(user.errors[:email]).to include("can't be blank")
	end


	it "the email address should be valid" do
		user =User.new(email: "Jack@163.com",password: "JackJackJack")
		expect(user).to be_valid
	end 
	it "the email address should be valid" do
		user =User.new(email: "Jack163.com",password: "JackJackJack")
		expect(user).not_to be_valid
	end 
	it "the email address should be valid" do
		user =User.new(email: "Jack@@163.com",password: "JackJackJack")
		expect(user).not_to be_valid
	end 
	it "the email address should be valid" do
		user =User.new(email: "Jack@163com",password: "JackJackJack")
		expect(user).not_to be_valid
	end 
	it "the email address should be valid" do
		user =User.new(email: "Jack@163com",password: "JackJackJack")
		invalid_address= %w(
			Jack163.com
			Jack@@163.com
			Jack@163com
		)
		invalid_address.each do |addr|
			user.email=addr
			expect(user).not_to be_valid
		end
	end

	it "the email address can not be duplicate" do
		user=User.new(email: "Jack@163.com", password: "JackJack")
		user1=user.clone
		user.save
		expect(user1).not_to be_valid
	end

	it "the password should not be shorter than 8 digits" do
		user =User.new(email: "Jack@163.com",password: "JackJac")
		expect(user).not_to be_valid
		#is too short
	end
	it "the password should be longer than 8 digits" do
		user =User.new(email: "Jack@163.com",password: "JackJack")
		expect(user).to be_valid
	end
	it "the password should be longer than 72 digits" do
		user =User.new(email: "Jack@163.com",password: "")
		user.password="a"*72
		expect(user).to be_valid
	end
		it "the password should not be longer than 72 digits" do
		user =User.new(email: "Jack@163.com",password: "")
		user.password="a"*73
		expect(user).not_to be_valid
		#is too long
	end
end