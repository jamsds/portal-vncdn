class MailerWorker
  class FreeTrial
  	include Sidekiq::Worker

  	def perform(username)
  		# Concept
  		# General email only receive username, and then exec email information with this username
  		# E.g which every user only one username, we can find name of user by username in template
	  	@username = username

	    NotificationMailer.trial_email(@username).deliver
	  end
  end
end