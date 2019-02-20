class CreateBandwidths < ActiveRecord::Migration[5.2]
  def change
    create_table :bandwidths do |t|
    	t.bigint  :user_id
      
      t.decimal :bandwidth_usage, precision: 15, scale: 2
      t.string  :monthly

      t.timestamps
    end

    add_index :bandwidths, [:user_id, :monthly], :unique => true
  end
end