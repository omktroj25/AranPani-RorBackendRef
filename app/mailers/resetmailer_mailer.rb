class ResetmailerMailer < ApplicationMailer
    def reset_password(user,url)
        @url=url
        p "inside mailer"
        mail(to:user.email, subject: "Reset password")
    end
end
