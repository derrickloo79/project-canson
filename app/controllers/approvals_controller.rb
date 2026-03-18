class ApprovalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_approving_manager!

  def index
    scope = current_user.role_system_admin? ? Event.all : Event.where(user: current_user.managed_users)
    @events = scope.status_pending_approval
                   .order(created_at: :asc)
                   .includes(:user, :event_roles)
  end

  private

  def authorize_approving_manager!
    unless current_user.role_approving_manager? || current_user.role_system_admin?
      redirect_to root_path, alert: "Not authorised."
    end
  end
end
