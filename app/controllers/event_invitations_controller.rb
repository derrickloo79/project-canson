class EventInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_ops_manager!
  before_action :set_event_role

  # DELETE /events/:event_id/event_roles/:event_role_id/event_invitations/:id
  def destroy
    inv = @event_role.event_invitations.find(params[:id])
    inv.update!(status: :withdrawn, responded_at: Time.current)
    redirect_to event_path(@event_role.event, anchor: "tab-staff"), notice: "Invitation withdrawn for #{inv.staff_member.name}."
  rescue ActiveRecord::RecordNotFound
    redirect_to event_path(@event_role.event, anchor: "tab-staff"), alert: "Invitation not found."
  end

  # POST /events/:event_id/event_roles/:event_role_id/event_invitations
  def create
    ids = Array(params[:staff_member_ids]).reject(&:blank?)
    if ids.empty?
      redirect_to event_path(@event_role.event, anchor: "tab-staff"), alert: "No staff selected." and return
    end

    invited = []
    errors  = []
    ids.each do |id|
      inv = @event_role.event_invitations.build(staff_member_id: id)
      if inv.save
        invited << inv.staff_member.name
      else
        errors << inv.errors.full_messages.to_sentence
      end
    end

    notice = invited.any? ? "Invited: #{invited.to_sentence}." : nil
    alert  = errors.any?  ? errors.uniq.to_sentence : nil
    redirect_to event_path(@event_role.event, anchor: "tab-staff"), notice: notice, alert: alert
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
