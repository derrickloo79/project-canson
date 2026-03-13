class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_flexible_staff!
  before_action :set_invitation, only: %i[accept decline]

  # GET /invitations
  def index
    if current_user.staff_member.nil?
      @pending_invitations   = []
      @responded_invitations = []
      return
    end
    all = current_user.staff_member
                      .event_invitations
                      .includes(event_role: :event)
                      .ordered_for_staff
    @pending_invitations   = all.select(&:status_pending?)
    @responded_invitations = all.reject(&:status_pending?)
  end

  # PATCH /invitations/:id/accept
  def accept
    @invitation.update!(status: :accepted, responded_at: Time.current)
    redirect_to invitations_path, notice: "You have accepted the invitation."
  end

  # PATCH /invitations/:id/decline
  def decline
    @invitation.update!(status: :declined, responded_at: Time.current)
    redirect_to invitations_path, notice: "You have declined the invitation."
  end

  private

  def set_invitation
    @invitation = current_user.staff_member.event_invitations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to invitations_path, alert: "Invitation not found."
  end

  def authorize_flexible_staff!
    redirect_to root_path, alert: "Not authorised." unless current_user.role_flexible_staff?
  end
end
