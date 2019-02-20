class ApiController < ApplicationController
	# For test Postman
	skip_before_action :verify_authenticity_token
end