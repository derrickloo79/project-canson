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

  has_many :events, foreign_key: :user_id, dependent: :destroy

  validates :name, presence: true
end
