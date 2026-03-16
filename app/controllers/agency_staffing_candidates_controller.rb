class AgencyStaffingCandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_ops_manager!
  before_action :set_candidate

  def accept
    @candidate.update!(status: :accepted, accepted_at: Time.current)
    redirect_to event_path(@candidate.agency_staffing_request.event_role.event, anchor: "tab-agencies"),
                notice: "#{@candidate.agency_staff_member.name} accepted."
  end

  def reject
    @candidate.update!(
      status: :rejected,
      rejected_at: Time.current,
      rejection_reason: params[:rejection_reason].to_s.strip.presence
    )
    redirect_to event_path(@candidate.agency_staffing_request.event_role.event, anchor: "tab-agencies"),
                notice: "#{@candidate.agency_staff_member.name} rejected."
  end

  private

  def set_candidate
    # Scope to events owned by current user for safety
    @candidate = AgencyStaffingCandidate
                   .joins(agency_staffing_request: { event_role: :event })
                   .where(events: { user_id: current_user.id })
                   .find(params[:id])
  end

  def authorize_ops_manager!
    redirect_to root_path, alert: "Not authorised." unless current_user.role_ops_manager?
  end
end