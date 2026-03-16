class AgencyConnection < ApplicationRecord
  belongs_to :agency
  belongs_to :confirmed_by, class_name: "User", optional: true

  enum :status, {
    pending:   0,
    active:    1,
    suspended: 2
  }, prefix: true

  def confirm!(user)
    update!(
      status:       :active,
      confirmed_by: user,
      confirmed_at: Time.current
    )
  end
end
