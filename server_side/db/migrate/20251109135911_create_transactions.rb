class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pgcrypto'

    create_table :transactions, id: :uuid do |t|
      t.string :type, null: false, index: true

      t.decimal :amount, precision: 10, scale: 2
      t.integer :status, null: false, default: 3
      t.string :customer_email, null: false
      t.string :customer_phone

      t.references :merchant, null: false, foreign_key: true
      t.references :reference_transaction, type: :uuid, foreign_key: { to_table: :transactions }

      t.timestamps
    end

    add_index :transactions, :status
  end
end
