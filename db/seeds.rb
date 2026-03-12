# Seeds are idempotent — safe to run multiple times.

# Ops Manager (primary test user)
ops = User.find_or_create_by!(email: "ops@example.com") do |u|
  u.name     = "Alex Chen"
  u.password = "password123"
  u.role     = :ops_manager
end
puts "Ops Manager: #{ops.email} / password123"

# Approving Manager
approver = User.find_or_create_by!(email: "approver@example.com") do |u|
  u.name     = "Sarah Wong"
  u.password = "password123"
  u.role     = :approving_manager
end
# Approver is their own approving manager (self-approver for testing auto-approval)
approver.update!(approving_manager: approver) if approver.approving_manager_id.nil?
puts "Approving Manager: #{approver.email} / password123"

# Wire ops manager to the approver
ops.update!(approving_manager: approver) if ops.approving_manager_id.nil?

# Second ops manager who is self-approving (no separate approver needed)
ops2 = User.find_or_create_by!(email: "ops2@example.com") do |u|
  u.name     = "Jordan Lee"
  u.password = "password123"
  u.role     = :ops_manager
end
ops2.update!(approving_manager: ops2) if ops2.approving_manager_id.nil?
puts "Ops Manager 2 (self-approver): #{ops2.email} / password123"

# Sample event in pending_approval status (for testing the approval queue)
unless ops.events.where(event_name: "Charity Gala Dinner 2026").exists?
  pending_event = ops.events.create!(
    event_name:       "Charity Gala Dinner 2026",
    event_type:       :gala,
    event_date:       Date.today + 45,
    venue:            "Crystal Ballroom, Level 3",
    reference_number: "EVT-2026-002",
    setup_time:       Time.parse("16:00"),
    event_start_time: Time.parse("19:00"),
    event_end_time:   Time.parse("23:00"),
    teardown_time:    Time.parse("23:30"),
    description:      "Annual charity gala for 250 guests.",
    status:           :pending_approval,
    wizard_step:      2
  )
  pending_event.event_roles.create!([
    { role_name: "Waiter", vacancies: 10, shift_start: Time.parse("18:00"), shift_end: Time.parse("23:30"), position: 1 },
    { role_name: "Bartender", vacancies: 2, shift_start: Time.parse("18:00"), shift_end: Time.parse("23:00"), position: 2 }
  ])
  pending_event.update_column(:wizard_step, 3)
  puts "Pending approval event created: #{pending_event.event_name}"
end

# Sample event in draft status (for testing the wizard flow)
unless ops.events.where(event_name: "Grand Annual Gala 2026").exists?
  # Build with wizard_step: 1 first so no step-3 validations fire,
  # then set wizard_step: 3 after roles are attached.
  event = ops.events.create!(
    event_name:       "Grand Annual Gala 2026",
    event_type:       :gala,
    event_date:       Date.today + 30,
    venue:            "Grand Ballroom, Level 4",
    reference_number: "EVT-2026-001",
    setup_time:       Time.parse("15:00"),
    event_start_time: Time.parse("18:30"),
    event_end_time:   Time.parse("23:00"),
    teardown_time:    Time.parse("23:30"),
    description:      "Annual company gala dinner for 300 guests. Full AV setup required.",
    status:           :draft,
    wizard_step:      2
  )

  event.event_roles.create!([
    {
      role_name:   "Head Waiter",
      vacancies:   2,
      shift_start: Time.parse("17:00"),
      shift_end:   Time.parse("23:30"),
      dress_code:  "Black formal with white gloves",
      requirements: "Min. 3 years banquet experience",
      position:    1
    },
    {
      role_name:   "Waiter",
      vacancies:   15,
      shift_start: Time.parse("17:30"),
      shift_end:   Time.parse("23:30"),
      dress_code:  "Black formal",
      requirements: nil,
      position:    2
    },
    {
      role_name:   "Bartender",
      vacancies:   3,
      shift_start: Time.parse("17:00"),
      shift_end:   Time.parse("23:00"),
      dress_code:  "Black formal",
      requirements: "Cocktail experience preferred",
      position:    3
    },
    {
      role_name:   "Registration Staff",
      vacancies:   4,
      shift_start: Time.parse("17:00"),
      shift_end:   Time.parse("19:30"),
      dress_code:  "Business formal",
      requirements: nil,
      position:    4
    }
  ])

  event.update_column(:wizard_step, 3)
  puts "Sample event created: #{event.event_name} (draft, #{event.event_roles.size} roles)"
end
