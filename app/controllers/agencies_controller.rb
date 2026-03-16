class AgenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_system_admin!

  def index
    @agencies = Agency.includes(:agency_connection, :invited_by).order(created_at: :desc)
  end

  def new
    @agency = Agency.new
  end

  def create
    @agency = Agency.new(agency_params)
    @agency.invited_by = current_user
    @agency.invitation_sent_at = Time.current

    if @agency.save
      AgencyMailer.invitation(@agency).deliver_later
      redirect_to agencies_path, notice: "Invitation sent to #{@agency.contact_email}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def agency_params
    params.require(:agency).permit(:name, :contact_email, :phone, :website)
  end

  def authorize_system_admin!
    redirect_to root_path, alert: "Not authorised." unless current_user.role_system_admin?
  end
end
