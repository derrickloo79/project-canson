class AgencyStaffingRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_ops_manager!
  before_action :set_event

  def create
    @request = @event.event_roles
                     .find(params[:agency_staffing_request][:event_role_id])
                     .agency_staffing_requests
                     .build(request_params)
    @request.requested_by = current_user

    if @request.save
      redirect_to event_path(@event, anchor: "tab-agencies"),
                  notice: "Staffing request sent to #{@request.agency.name}."
    else
      redirect_to event_path(@event, anchor: "tab-agencies"),
                  alert: @request.errors.full_messages.to_sentence
    end
  end

  def destroy
    @staffing_request = AgencyStaffingRequest
                          .joins(:event_role)
                          .where(event_roles: { event_id: @event.id })
                          .find(params[:id])
    @staffing_request.update!(status: :cancelled)
    redirect_to event_path(@event, anchor: "tab-agencies"),
                notice: "Request to #{@staffing_request.agency.name} was cancelled."
  end

  private

  def set_event
    @event = current_user.events.find(params[:event_id])
  end

  def request_params
    params.require(:agency_staffing_request).permit(:agency_id, :vacancies_requested, :notes)
  end

  def authorize_ops_manager!
    redirect_to root_path, alert: "Not authorised." unless current_user.role_ops_manager?
  end
end
