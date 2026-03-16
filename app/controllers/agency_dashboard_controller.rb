class AgencyDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_agency_user!
  before_action :set_connection

  def show
  end

  def confirm
    unless current_user.role_agency_admin?
      redirect_to agency_dashboard_path, alert: "Not authorised."
      return
    end

    if @connection.status_active?
      redirect_to agency_dashboard_path, notice: "Connection is already active."
      return
    end

    @connection.confirm!(current_user)
    redirect_to agency_dashboard_path, notice: "Connection confirmed. You are now connected to the hotel."
  end

  private

  def set_connection
    @connection = current_user.agency&.agency_connection
  end

  def authorize_agency_user!
    redirect_to root_path, alert: "Not authorised." unless current_user.agency_user?
  end
end
