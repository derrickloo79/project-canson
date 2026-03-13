class EventInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_ops_manager!
  before_action :set_event_role

  # POST /events/:event_id/event_roles/:event_role_id/event_invitations
  def create
    @invitation = @event_role.event_invitations.build(staff_member_id: params[:staff_member_id])
    if @invitation.save
      redirect_to event_path(@event_role.event),
        notice: "#{@invitation.staff_member.name} invited for #{@event_role.role_name}."
    else
      redirect_to event_path(@event_role.event),
        alert: @invitation.errors.full_messages.to_sentence
    end
  end

  private

  def set_event_role
    event = current_user.events.find(params[:event_id])
    @event_role = event.event_roles.find(params[:event_role_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Not authorised."
  end

  def authorize_ops_manager!
    redirect_to root_path, alert: "Not authorised." unless current_user.role_ops_manager?
  end
end
