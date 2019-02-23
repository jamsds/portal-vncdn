class CreateNotifications < ActiveRecord::Migration[5.2]
    def change
        create_table :notifications do |t|
        t.bigint  :user_id

        t.boolean :notify_general,        default: true
        t.boolean :notify_billing,        default: true
        t.boolean :notify_product,        default: true
        t.boolean :notify_transaction,    default: true
        t.boolean :notify_subscription,   default: true
        t.boolean :notify_credit,         default: false
        t.boolean :notify_support,        default: false
        t.boolean :notify_reseller,       default: false
    end

    add_index :notifications, [:user_id], :unique => true
    end
end
