class CreateStorages < ActiveRecord::Migration[5.2]
  def change
    create_table :storages do |t|
    t.bigint    :user_id

    t.decimal   :storage_usage, precision: 15, scale: 2, default: 0
    t.string    :monthly

    t.datetime  :last_update
    t.timestamps
  end

  add_index :storages, [:user_id, :monthly], :unique => true
  end
end