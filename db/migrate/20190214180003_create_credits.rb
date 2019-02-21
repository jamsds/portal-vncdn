class CreateCredits < ActiveRecord::Migration[5.2]
  def change
		create_table :credits do |t|
		t.bigint 	:user_id

		t.string 	:name
		t.integer :payment_type, default: 1

		# Payment with Stripe
    t.string  :stripe_token

		t.decimal :credit_value, precision: 15, scale: 2, default: 0
		t.boolean	:active,       default: true
	end

	add_index :credits, [:user_id], :unique => true
  end
end