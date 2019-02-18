class Credit < ApplicationRecord
	belongs_to :user

	# Credit Log Daily
	has_many :cashes, dependent: :destroy

	# Credit Transaction Monthly
	has_many :transactions, dependent: :destroy

	validates_uniqueness_of :user_id, scope: %i[user_id]
end