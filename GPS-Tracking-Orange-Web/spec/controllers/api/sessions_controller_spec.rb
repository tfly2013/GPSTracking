require 'rails_helper'

RSpec.describe Api::SessionsController, type: :controller do
   describe "POST #create" do
    it "sign in successfully" do
      @request.headers["Accept"] = "application/json"
      post :create, { user_email: "feit@test.com", user_token: "syeN8T14SDrSp1HAxDkT" }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      
    end
  end
end
