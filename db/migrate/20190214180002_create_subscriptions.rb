class CreateSubscriptions < ActiveRecord::Migration[5.2]
    def change
        create_table :subscriptions do |t|
        t.bigint   :user_id

        # subscription name automatic generate base on user name and uuid
        t.string   :name

        # define package info
        t.integer  :package

        # subscription_type == 1 is free trial
        # subscription_type == 2 is invidual account
        # subscription_type == 3 is special account
        t.integer  :subscription_type,             default: 1

        # payment_type == 1 is free
        # payment_type == 2 is automatic payment
        # payment_type == 3 is manual payment
        t.integer  :payment_type,                  default: 1

        # subscription_type == 1 & 2
        # traffic & storage usage limit per month
        # reseller or admin can modify this limit, every subscription modified will change to subscription_type == 2
        t.decimal  :bwd_limit,      precision: 15, default: 0
        t.decimal  :stg_limit,      precision: 15, default: 0

        # reseller or admin can modify this pricing, every subscription modified will change to subscription_type == 2
        t.decimal  :bwd_price,      precision: 15, default: 0
        t.decimal  :stg_price,      precision: 15, default: 0

        # traffic & storage price over usage limit
        t.decimal  :bwd_price_over, precision: 15, default: 0
        t.decimal  :stg_price_over, precision: 15, default: 0

        # user can add more traffic & storage as add-on service
        t.decimal  :bwd_add,        precision: 15, default: 0
        t.decimal  :stg_add,        precision: 15, default: 0

        # pricing for payment_type == 3, user will make payment with invoice
        t.decimal  :pricing,        precision: 15, default: 0

        # Define Reseller Owner Package
        t.string   :reseller

        # Manage Subscription
        t.integer  :status,    default: 1
        t.datetime :expiration_date
    end

    add_index :subscriptions, [:user_id], :unique => true
    end
end
