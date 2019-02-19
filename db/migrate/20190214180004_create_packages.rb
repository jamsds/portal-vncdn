class CreatePackages < ActiveRecord::Migration[5.2]
  def change
    create_table :packages do |t|
    	t.string  :name

    	t.decimal :bwd_limit,          precision: 15, default: 0
    	t.decimal :stg_limit,          precision: 15, default: 0

    	t.decimal :bwd_price,          precision: 15, default: 0
    	t.decimal :stg_price,          precision: 15, default: 0

        t.decimal :bwd_price_over,     precision: 15, default: 0
        t.decimal :stg_price_over,     precision: 15, default: 0

        t.string  :reseller

        # Pricing for Subscription Type 2
    	t.decimal :pricing,              precision: 15, default: 0
    end
  end
end