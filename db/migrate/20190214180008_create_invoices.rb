class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
    	t.bigint   :credit_id

    	t.string   :description
      t.string   :invoice_type

      # Price value
      t.decimal  :amount,  precision: 15, scale: 2, default: 0

      # Invoice Status
      t.string   :status

      # for bandwidth & storage usage
      t.decimal  :value,   precision: 15, scale: 2, default: 0

      t.string   :monthly
      t.timestamps
    end
  end
end
