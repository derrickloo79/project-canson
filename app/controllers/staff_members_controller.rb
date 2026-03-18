class StaffMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff_access!
  before_action :set_staff_member, only: %i[show edit update destroy blacklist unblacklist create_login reset_password]

  def index
    @staff_members = StaffMember.ordered.includes(:roles)
  end

  def show
  end

  def new
    @staff_member = StaffMember.new
  end

  def create
    @staff_member = StaffMember.new(staff_member_params)
    if @staff_member.save
      redirect_to staff_members_path, notice: "Staff member \"#{@staff_member.name}\" added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @staff_member.update(staff_member_params)
      redirect_to staff_member_path(@staff_member), notice: "Staff member updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @staff_member.destroy
    redirect_to staff_members_path, notice: "Staff member \"#{@staff_member.name}\" removed."
  end

  # POST /staff_members/:id/create_login
  def create_login
    if @staff_member.has_login?
      redirect_to staff_member_path(@staff_member), alert: "This staff member already has a login."
      return
    end
    temp_password = SecureRandom.alphanumeric(12)
    user = User.new(
      email:    @staff_member.email,
      name:     @staff_member.name,
      password: temp_password,
      role:     :flexible_staff
    )
    if user.save
      @staff_member.update!(user: user)
      flash[:temp_password] = temp_password
      redirect_to staff_member_path(@staff_member), notice: "Login created for #{@staff_member.name}."
    else
      redirect_to staff_member_path(@staff_member),
        alert: "Could not create login: #{user.errors.full_messages.to_sentence}"
    end
  end

  # POST /staff_members/:id/reset_password
  def reset_password
    unless @staff_member.has_login?
      redirect_to staff_member_path(@staff_member), alert: "This staff member has no login to reset."
      return
    end
    temp_password = SecureRandom.alphanumeric(12)
    @staff_member.user.update!(password: temp_password)
    flash[:temp_password] = temp_password
    redirect_to staff_member_path(@staff_member), notice: "Password reset for #{@staff_member.name}."
  end

  # PATCH /staff_members/:id/blacklist
  def blacklist
    authorize_blacklist_manager!
    reason = params[:blacklist_reason].to_s.strip
    if reason.blank?
      redirect_to staff_member_path(@staff_member), alert: "Please provide a reason for blacklisting."
    else
      @staff_member.blacklist!(by_user: current_user, reason: reason)
      redirect_to staff_member_path(@staff_member), notice: "\"#{@staff_member.name}\" has been blacklisted."
    end
  end

  # PATCH /staff_members/:id/unblacklist
  def unblacklist
    authorize_blacklist_manager!
    @staff_member.unblacklist!
    redirect_to staff_member_path(@staff_member), notice: "\"#{@staff_member.name}\" has been reinstated."
  end

  private

  def set_staff_member
    @staff_member = StaffMember.find(params[:id])
  end

  def staff_member_params
    params.require(:staff_member).permit(:name, :email, :mobile, :gender, :active, role_ids: [])
  end

  # Ops managers and above can access staff directory
  def authorize_staff_access!
    unless current_user.role_ops_manager? ||
           current_user.role_approving_manager? ||
           current_user.role_system_admin?
      redirect_to root_path, alert: "Not authorised."
    end
  end

  # Only approving managers and admins can blacklist/unblacklist
  def authorize_blacklist_manager!
    unless current_user.role_approving_manager? || current_user.role_system_admin?
      redirect_to staff_member_path(@staff_member), alert: "Not authorised."
    end
  end
end
