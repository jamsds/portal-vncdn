class Bandwidth < ApplicationRecord
	belongs_to :user
	validates_uniqueness_of :user_id, scope: %i[monthly]
end