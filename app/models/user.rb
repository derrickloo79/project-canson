class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    system_admin:      0,
    approving_manager: 1,
    ops_manager:       2,
    flexible_staff:    3,
    agency_admin:      4,
    agency_manager:    5
  }, prefix: true

  belongs_to :approving_manager, class_name: "User", optional: true
  has_many :managed_users, class_name: "User", foreign_key: :approving_manager_id, dependent: :nullify

  has_many :events, foreign_key: :user_id, dependent: :destroy
  has_one :staff_member
  belongs_to :agency, optional: true

  validates :name, presence: true

  def self_approver?
    approving_manager_id.present? && approving_manager_id == id
  end

  def agency_user?
    role_agency_admin? || role_agency_manager?
  end
end
