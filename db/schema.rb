# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_14_180008) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bandwidths", force: :cascade do |t|
    t.bigint "user_id"
    t.decimal "bandwidth_usage", precision: 15, scale: 2, default: "0.0"
    t.string "monthly"
    t.datetime "last_update"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "monthly"], name: "index_bandwidths_on_user_id_and_monthly", unique: true
  end

  create_table "credits", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.integer "payment_type", default: 1
    t.decimal "credit_value", precision: 15, scale: 2, default: "0.0"
    t.string "stripe_token"
    t.string "card_token"
    t.string "card_brand"
    t.string "card_name"
    t.string "expires"
    t.string "last4"
    t.string "funding"
    t.boolean "active", default: true
    t.index ["user_id"], name: "index_credits_on_user_id", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "credit_id"
    t.string "description"
    t.string "invoice_type"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0"
    t.string "status"
    t.decimal "value", precision: 15, scale: 2, default: "0.0"
    t.string "monthly"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "notify_general", default: true
    t.boolean "notify_billing", default: true
    t.boolean "notify_product", default: true
    t.boolean "notify_transaction", default: true
    t.boolean "notify_subscription", default: true
    t.boolean "notify_credit", default: false
    t.boolean "notify_support", default: false
    t.boolean "notify_reseller", default: false
    t.index ["user_id"], name: "index_notifications_on_user_id", unique: true
  end

  create_table "packages", force: :cascade do |t|
    t.string "name"
    t.decimal "bwd_limit", precision: 15
    t.decimal "stg_limit", precision: 15
    t.decimal "bwd_price", precision: 15
    t.decimal "stg_price", precision: 15
    t.decimal "bwd_price_over", precision: 15
    t.decimal "stg_price_over", precision: 15
    t.string "reseller"
    t.decimal "pricing", precision: 15
  end

  create_table "storages", force: :cascade do |t|
    t.bigint "user_id"
    t.decimal "storage_usage", precision: 15, scale: 2, default: "0.0"
    t.string "monthly"
    t.datetime "last_update"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "monthly"], name: "index_storages_on_user_id_and_monthly", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.integer "package"
    t.integer "subscription_type", default: 1
    t.integer "payment_type", default: 1
    t.decimal "bwd_limit", precision: 15
    t.decimal "stg_limit", precision: 15
    t.decimal "bwd_price", precision: 15
    t.decimal "stg_price", precision: 15
    t.decimal "bwd_price_over", precision: 15
    t.decimal "stg_price_over", precision: 15
    t.decimal "bwd_add", precision: 15
    t.decimal "stg_add", precision: 15
    t.decimal "pricing", precision: 15
    t.string "reseller"
    t.integer "status", default: 1
    t.datetime "expiration_date"
    t.index ["user_id"], name: "index_subscriptions_on_user_id", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "credit_id"
    t.string "description"
    t.string "transaction_type"
    t.string "stripe_id"
    t.string "transaction_error"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0"
    t.string "card_id"
    t.string "card_name"
    t.string "card_number"
    t.string "card_brand"
    t.string "status"
    t.decimal "value", precision: 15, scale: 2, default: "0.0"
    t.string "monthly"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username"
    t.string "name"
    t.string "phone"
    t.string "company"
    t.integer "accountType", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.integer "uuid"
    t.string "parent_uuid"
    t.integer "admin_id"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.bigint "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "domain"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
