class CreateMerchants < ActiveRecord::Migration[8.1]
  def change
    create_table :merchants do |t|
      t.string :name
      t.text :description
      t.integer :status
      t.decimal :total_transaction_sum, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
