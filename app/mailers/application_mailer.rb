class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  before_action :default_url_options

  private
  	def default_url_options
	    { @host = request.host_with_port }
	  end
end
