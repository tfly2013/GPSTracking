require 'rails_helper'

RSpec.describe "Reports", type: :request do
  describe "GET /reports" do
    it "works! " do
      get user_report_path
      expect(response).to have_http_status(302)
    end
  end
end
