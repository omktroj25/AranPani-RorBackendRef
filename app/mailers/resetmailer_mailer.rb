class ResetmailerMailer < ApplicationMailer
    def reset_password(user,url)
        @url=url
        mail(to:user.email, subject: "Reset password")
    end
end
