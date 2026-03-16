class AgencyIncomingRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_agency_user!
  before_action :set_agency
  before_action :set_request, only: %i[show decline submit_candidates]

  def index
    @requests = @agency.agency_staffing_requests
                       .includes(event_role: :event, agency_staffing_candidates: :agency_staff_member)
                       .order(created_at: :desc)
  end

  def show
    @roster = @agency.agency_staff_members.active.ordered.includes(:roles)
    @submitted_ids = @request.agency_staffing_candidates.pluck(:agency_staff_member_id)
  end

  def decline
    reason = params[:declined_reason].to_s.strip
    @request.update!(status: :declined, declined_reason: reason, declined_at: Time.current)
    redirect_to agency_incoming_requests_path,
                notice: "Request for #{@request.event_role.role_name} declined."
  end

  def submit_candidates
    ids = Array(params[:agency_staff_member_ids]).map(&:to_i).uniq
    already_submitted = @request.agency_staffing_candidates.pluck(:agency_staff_member_id)
    new_ids = ids - already_submitted

    new_ids.each do |member_id|
      member = @agency.agency_staff_members.find_by(id: member_id)
      next unless member

      @request.agency_staffing_candidates.create!(agency_staff_member: member)
    end

    @request.update!(status: :submitted, submitted_at: Time.current) if @request.status_pending?

    redirect_to agency_incoming_request_path(@request),
                notice: "#{new_ids.size} candidate(s) submitted."
  end

  private

  def set_agency
    @agency = current_user.agency
  end

  def set_request
    @request = @agency.agency_staffing_requests.find(params[:id])
  end

  def authorize_agency_user!
    redirect_to root_path, alert: "Not authorised." unless current_user.agency_user?
  end
end