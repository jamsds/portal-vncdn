class CreateCredits < ActiveRecord::Migration[5.2]
  def change
		create_table :credits do |t|
		t.bigint 	:user_id

		t.string 	:name
		t.integer :payment_type, default: 1

		t.decimal :credit_value, precision: 15, scale: 2, default: 0

		# Payment with Stripe
    t.string  :stripe_token
    t.string  :card_token
    t.string	:card_brand
    t.string	:card_name
    t.string	:expires
    t.string	:last4
    t.string	:funding

		t.boolean	:active,       default: true
	end

	add_index :credits, [:user_id], :unique => true
  end
end