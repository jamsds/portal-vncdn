class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
    	t.bigint   :credit_id
    	
      t.string   :description
      t.string   :transaction_type

      # Check payment on stripe
      t.string   :stripe_id

      # Price value
      t.decimal  :amount,  precision: 15, scale: 2, default: 0

      # Transaction Card
      t.string   :card_id
      t.string   :card_name
      t.string   :card_number
      t.string   :card_brand

      # Transaction Status
      t.string   :status

      # for bandwidth & storage usage
      t.decimal  :value,   precision: 15, scale: 2, default: 0

    	t.string   :monthly
      t.timestamps
    end
  end
end
