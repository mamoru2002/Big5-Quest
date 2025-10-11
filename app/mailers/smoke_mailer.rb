class SmokeMailer < ApplicationMailer
  def hello(to)
    mail(to:, subject: "Hello from BIG5-Quest") do |format|
      format.text { render plain: "It works!" }
    end
  end
end
