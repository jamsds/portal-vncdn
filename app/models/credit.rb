class Credit < ApplicationRecord
	belongs_to :user
	validates_uniqueness_of :user_id, scope: %i[user_id]

	# Transactions
	has_many :transactions, dependent: :destroy

	# Invoices
	has_many :invoices, dependent: :destroy
end