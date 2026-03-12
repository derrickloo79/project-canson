class ApprovalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_approving_manager!

  def index
    @events = Event.status_pending_approval
                   .where(user: current_user.managed_users)
                   .order(created_at: :asc)
                   .includes(:user, :event_roles)
  end

  private

  def authorize_approving_manager!
    redirect_to root_path, alert: "Not authorised." unless current_user.role_approving_manager?
  end
end
