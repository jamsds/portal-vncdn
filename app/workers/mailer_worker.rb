class MailerWorker
  class FreeTrial
  	include Sidekiq::Worker

  	def perform(id)
  		# Concept
  		# General email only receive username, and then exec email information with this username
  		# E.g which every user only one username, we can find name of user by username in template
	  	@id = id

	    NotificationMailer.trial_email(@id).deliver
	  end
  end

  class NewCard
    include Sidekiq::Worker

    def perform(id)
      # Concept
      # General email only receive username, and then exec email information with this username
      # E.g which every user only one username, we can find name of user by username in template
      @id = id

      NotificationMailer.new_card_email(@id).deliver
    end
  end
end