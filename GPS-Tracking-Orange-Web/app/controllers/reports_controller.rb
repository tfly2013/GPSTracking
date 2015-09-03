class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_and_researcher_only

  # GET /reports
  # GET /reports.json
  def index
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
  end 
  
  def admin_and_researcher_only
    unless current_user.admin? || current_user.researcher?
      redirect_to :back, :alert => "Access denied."
    end
  end
end
