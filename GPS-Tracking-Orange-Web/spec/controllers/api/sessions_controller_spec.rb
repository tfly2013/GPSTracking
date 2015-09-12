require 'rails_helper'

RSpec.describe Api::SessionsController, type: :controller do
   describe "POST #create" do
    # it "sign in successfully" do
    #   @request.env["devise.mapping"] = Devise.mappings[:user]
    #   @request.headers["Accept"] = "application/json"
    #   @request.env["HTTP_ACCEPT"] = "application/json"
    #   @request.env["CONTENT_TYPE"] = "application/json"
    #   post :create, { user_email: "feit@test.com", user_token: "syeN8T14SDrSp1HAxDkT" }, as: :json
    #   #expect(response).to be_success
    #   expect(response).to have_http_status(200)
    # end

  # 	 it 'should have a current user sign in successfully' do
		# @request.env["devise.mapping"] = Devise.mappings[:user]
		# @request.headers["Accept"] = "application/json"
		# @request.env["CONTENT_TYPE"] = "application/json"

  # 		#user = login_user
  # 		post :create, { :user_email => "feit@test.com", :user_token => "syeN8T14SDrSp1HAxDkT" }, as: :json
  #    	#note the fact that you should remove the "validate_session" parameter if this was a scaffold-generated controller
  #   	expect(:current_user).not_to be_nil
  #   	#expect(response).to have_http_status(200)
  #   	expect(response).to be_success
  #   	#expect(assigns(:json["info"])).to eq("Logged in")
  #   	expect(json["success"]).to be_true
  # 	 end

  	 it 'sign in successfully' do
		  @request.headers["Accept"] = "application/json"
		  @request.env["CONTENT_TYPE"] = "application/json"
		  user=login_user
  		#server_response = post :create, { :email => user.email, :auth_token => user.authentication_token }, as: :json
     	server_response = post :create
      json = JSON.parse server_response.body
    	expect(response).to have_http_status(200)
    	expect(response).to be_success
      expect(json['success']).to eq(true)
    	expect(json['info']).to eq("Logged in")
      expect(json['data']['email']).to eq(user.email)
      expect(json['data']['auth_token']).to eq(user.authentication_token)
  	 end

     it 'did not sign in, then failed' do
      @request.headers["Accept"] = "application/json"
      @request.env["CONTENT_TYPE"] = "application/json"
      @request.env["devise.mapping"] = Devise.mappings[:user]
      server_response = post :create
      json = JSON.parse server_response.body
      expect(response).to have_http_status(401)
      expect(response).not_to be_success
      expect(json['error']).to eq("You need to sign in or sign up before continuing.")
     end

  end

   describe "POST #destroy" do
   		it 'sign out successfully' do
   		@request.headers["Accept"] = "application/json"
      @request.env["CONTENT_TYPE"] = "application/json"
  		user = login_user
  		server_response = delete :destroy
      json = JSON.parse server_response.body
    	expect(response).to have_http_status(200)
    	expect(response).to be_success
      expect(json['success']).to eq(true)
      expect(json['info']).to eq("Logged out")
      expect(json['data']).to eq({})
   		end
      it 'did not sign in then failed' do
      @request.headers["Accept"] = "application/json"
      @request.env["CONTENT_TYPE"] = "application/json"
      @request.env["devise.mapping"] = Devise.mappings[:user]
      server_response = delete :destroy
      json = JSON.parse server_response.body
      expect(response).to have_http_status(401)
      expect(response).not_to be_success
      expect(json['error']).to eq("You need to sign in or sign up before continuing.")
     end
   end


end
