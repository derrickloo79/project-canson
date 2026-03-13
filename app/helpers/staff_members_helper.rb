module StaffMembersHelper
  def can_edit_staff?
    current_user.role_ops_manager? ||
      current_user.role_approving_manager? ||
      current_user.role_system_admin?
  end

  def can_blacklist?
    current_user.role_approving_manager? || current_user.role_system_admin?
  end
end
