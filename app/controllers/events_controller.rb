class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show step1 step2 step3
                                     update_step1 update_step2 update_step3
                                     save_draft destroy approve reject]
  before_action :authorize_ops_manager!, only: %i[new create step1 step2 step3
                                                   update_step1 update_step2 update_step3
                                                   save_draft destroy]
  before_action :authorize_approver!, only: %i[approve reject]

  # GET /events
  def index
    scope = (current_user.role_approving_manager? || current_user.role_system_admin?) ? Event.all : current_user.events
    @events = scope.includes(:user).order(created_at: :desc)
  end

  # GET /events/new — immediately creates a bare draft and redirects to step 1
  def new
    @event = current_user.events.build
  end

  # POST /events
  def create
    @event = current_user.events.build(status: :draft, wizard_step: 1)
    if @event.save(validate: false)
      redirect_to step1_event_path(@event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /events/:id
  def show
    @event.event_roles.includes(
      event_invitations: :staff_member,
      agency_staffing_requests: { agency_staffing_candidates: :agency_staff_member }
    ).load
    @connected_agencies = AgencyConnection.status_active.includes(:agency).map(&:agency)
  end

  # GET /events/:id/step1
  def step1
  end

  # PATCH /events/:id/update_step1
  def update_step1
    new_wizard_step = [ 2, @event.wizard_step ].max
    if @event.update(step1_params.merge(wizard_step: new_wizard_step))
      redirect_to step2_event_path(@event)
    else
      render :step1, status: :unprocessable_entity
    end
  end

  # GET /events/:id/step2
  def step2
    @event.event_roles.build if @event.event_roles.empty?
  end

  # PATCH /events/:id/update_step2
  def update_step2
    new_wizard_step = [ 3, @event.wizard_step ].max
    if @event.update(step2_params.merge(wizard_step: new_wizard_step))
      redirect_to step3_event_path(@event)
    else
      @event.event_roles.build if @event.event_roles.empty?
      render :step2, status: :unprocessable_entity
    end
  end

  # GET /events/:id/step3
  def step3
  end

  # PATCH /events/:id/save_draft — save without validation, return to event list
  def save_draft
    @event.assign_attributes(draft_params)
    @event.save(validate: false)
    redirect_to events_path, notice: "Draft saved."
  end

  # DELETE /events/:id
  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event deleted."
  end

  # PATCH /events/:id/update_step3
  def update_step3
    @event.wizard_step = 3
    new_status = current_user.self_approver? ? :approved : :pending_approval
    if @event.update(status: new_status)
      notice = current_user.self_approver? ? "Event auto-approved." : "Event submitted for approval."
      redirect_to @event, notice: notice
    else
      render :step3, status: :unprocessable_entity
    end
  end

  # PATCH /events/:id/approve
  def approve
    @event.update!(status: :approved, rejection_reason: nil)
    redirect_to approvals_path, notice: "\"#{@event.event_name}\" has been approved."
  end

  # PATCH /events/:id/reject
  def reject
    reason = params[:rejection_reason].to_s.strip
    if reason.blank?
      redirect_to approvals_path, alert: "Please provide a rejection reason."
    else
      @event.update!(status: :rejected, rejection_reason: reason)
      redirect_to approvals_path, notice: "\"#{@event.event_name}\" has been rejected."
    end
  end

  private

  def set_event
    scope = (current_user.role_approving_manager? || current_user.role_system_admin?) ? Event.all : current_user.events
    @event = scope.find(params[:id])
  end

  def authorize_ops_manager!
    unless current_user.role_ops_manager? || current_user.role_system_admin?
      redirect_to root_path, alert: "You are not authorised to perform this action."
    end
  end

  def authorize_approver!
    is_approving_manager = current_user.role_approving_manager? &&
                           current_user.managed_users.include?(@event.user)
    unless is_approving_manager || current_user.role_system_admin?
      redirect_to root_path, alert: "You are not authorised to perform this action."
    end
  end

  def step1_params
    params.require(:event).permit(
      :event_name, :event_type, :event_date, :event_end_date,
      :multi_day, :venue, :reference_number, :setup_time,
      :event_start_time, :event_end_time, :end_time_next_day,
      :teardown_time, :teardown_next_day, :description
    )
  end

  def step2_params
    params.require(:event).permit(
      event_roles_attributes: [
        :id, :role_name, :vacancies, :shift_start,
        :shift_end, :shift_end_next_day, :rate, :requirements, :position, :_destroy
      ]
    )
  end

  def draft_params
    params.fetch(:event, {}).permit(
      :event_name, :event_type, :event_date, :event_end_date,
      :multi_day, :venue, :reference_number, :setup_time,
      :event_start_time, :event_end_time, :end_time_next_day,
      :teardown_time, :teardown_next_day, :description,
      event_roles_attributes: [
        :id, :role_name, :vacancies, :shift_start,
        :shift_end, :shift_end_next_day, :rate, :requirements, :position, :_destroy
      ]
    )
  end
end
