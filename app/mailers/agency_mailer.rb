class AgencyMailer < ApplicationMailer
  def invitation(agency)
    @agency           = agency
    @registration_url = agency_signup_url(token: agency.invitation_token)
    @invited_by_name  = agency.invited_by.name

    mail(
      to:      agency.contact_email,
      subject: "You've been invited to join FlexiLabour"
    )
  end
end
