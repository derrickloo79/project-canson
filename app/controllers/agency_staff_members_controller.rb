class AgencyStaffMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_agency_user!
  before_action :set_agency
  before_action :set_staff_member, only: %i[edit update destroy]

  def index
    @staff_members = @agency.agency_staff_members.ordered.includes(:roles)
  end

  def new
    @staff_member = @agency.agency_staff_members.build
  end

  def create
    @staff_member = @agency.agency_staff_members.build(staff_member_params)
    if @staff_member.save
      if params[:add_another]
        redirect_to new_agency_staff_member_path, notice: "#{@staff_member.name} was added. Add another below."
      else
        redirect_to agency_staff_members_path, notice: "#{@staff_member.name} was added to your roster."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @staff_member.update(staff_member_params)
      redirect_to agency_staff_members_path, notice: "#{@staff_member.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @staff_member.name
    @staff_member.destroy
    redirect_to agency_staff_members_path, notice: "#{name} was removed from your roster."
  end

  private

  def set_agency
    @agency = current_user.agency
  end

  def set_staff_member
    @staff_member = @agency.agency_staff_members.find(params[:id])
  end

  def staff_member_params
    params.require(:agency_staff_member).permit(:name, :email, :mobile, :gender, :active, role_ids: [])
  end

  def authorize_agency_user!
    redirect_to root_path, alert: "Not authorised." unless current_user.agency_user?
  end
end
