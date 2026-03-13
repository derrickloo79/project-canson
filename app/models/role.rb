class Role < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :ordered,  -> { order(:name) }
  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
