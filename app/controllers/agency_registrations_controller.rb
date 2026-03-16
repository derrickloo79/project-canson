class AgencyRegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  before_action :load_agency

  def new
    if @agency.registered?
      redirect_to new_user_session_path, notice: "#{@agency.name} is already registered. Please sign in."
      return
    end
    @user = User.new(email: @agency.contact_email)
  end

  def create
    if @agency.registered?
      redirect_to new_user_session_path, notice: "#{@agency.name} is already registered. Please sign in."
      return
    end

    @user = User.new(user_params.merge(role: :agency_admin, agency: @agency))

    ActiveRecord::Base.transaction do
      @user.save!
      @agency.update!(invitation_accepted_at: Time.current)
      AgencyConnection.create!(agency: @agency, status: :pending)
    end

    sign_in(@user)
    redirect_to agency_dashboard_path,
      notice: "Welcome to FlexiLabour! Please confirm your connection with the hotel to get started."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def load_agency
    @agency = Agency.find_by!(invitation_token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to new_user_session_path, alert: "Invalid or expired invitation link."
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
