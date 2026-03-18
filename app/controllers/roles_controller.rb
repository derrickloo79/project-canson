class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_approving_manager!
  before_action :set_role, only: %i[edit update destroy toggle]

  def index
    @roles = Role.ordered
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to roles_path, notice: "Role \"#{@role.name}\" created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @role.update(role_params)
      redirect_to roles_path, notice: "Role updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @role.destroy
    redirect_to roles_path, notice: "Role deleted."
  end

  # PATCH /roles/:id/toggle
  def toggle
    @role.update!(active: !@role.active)
    status = @role.active? ? "enabled" : "disabled"
    redirect_to roles_path, notice: "Role \"#{@role.name}\" #{status}."
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name)
  end

  def authorize_approving_manager!
    unless current_user.role_approving_manager? || current_user.role_system_admin?
      redirect_to root_path, alert: "Not authorised."
    end
  end
end
