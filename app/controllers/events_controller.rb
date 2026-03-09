class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show step1 step2 step3
                                     update_step1 update_step2 update_step3]
  before_action :authorize_ops_manager!, only: %i[new create step1 step2 step3
                                                   update_step1 update_step2 update_step3]

  # GET /events
  def index
    @events = current_user.events.order(created_at: :desc)
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

  # PATCH /events/:id/update_step3
  def update_step3
    @event.wizard_step = 3
    if @event.update(status: :pending_approval)
      redirect_to @event, notice: "Event submitted for approval."
    else
      render :step3, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def authorize_ops_manager!
    unless current_user.role_ops_manager?
      redirect_to root_path, alert: "You are not authorised to perform this action."
    end
  end

  def step1_params
    params.require(:event).permit(
      :event_name, :event_type, :event_date, :event_end_date,
      :multi_day, :venue, :reference_number, :setup_time,
      :event_start_time, :event_end_time, :teardown_time, :description
    )
  end

  def step2_params
    params.require(:event).permit(
      event_roles_attributes: [
        :id, :role_name, :vacancies, :shift_start,
        :shift_end, :rate, :requirements, :position, :_destroy
      ]
    )
  end
end
