# app/mailers/import_mailer.rb
class ImportMailer < ApplicationMailer
    default from: "no-reply@example.com"

    def import_finished
      @user   = params[:user]
      @result = params[:result]
      mail(to: @user.email, subject: "Your import has finished") do |format|
        format.text
        format.html
      end
    end
end
