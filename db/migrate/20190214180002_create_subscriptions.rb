class CreateSubscriptions < ActiveRecord::Migration[5.2]
    def change
        create_table :subscriptions do |t|
        t.bigint   :user_id

        # Subsciption Name
        t.string   :name

        # Subscription Type
        # 1. Pay as you go
        # 2. Monthly
        # 3. Trial
        # 4. Scalable
        t.integer  :subscription_type,        default: 1

        # Normal Subscription
        t.decimal  :bwd_limit,      precision: 15, default: 0
        t.decimal  :stg_limit,      precision: 15, default: 0

        t.decimal  :bwd_price,      precision: 15, default: 0
        t.decimal  :stg_price,      precision: 15, default: 0

        t.decimal  :bwd_price_over, precision: 15, default: 0
        t.decimal  :stg_price_over, precision: 15, default: 0

        t.decimal  :bwd_add,        precision: 15, default: 0
        t.decimal  :stg_add,        precision: 15, default: 0

        # Pricing for Subscription Type 2
        t.decimal  :pricing,        precision: 15, default: 0

        # Manage Subscription
        t.integer  :status,    default: 1
        t.datetime :expiration_date
    end

    add_index :subscriptions, [:user_id], :unique => true
    end
end
