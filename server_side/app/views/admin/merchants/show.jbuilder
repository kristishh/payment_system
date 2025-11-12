json.merchant do
  json.extract! @merchant, :id, :name, :description, :status
  json.extract! @merchant.user, :email
  json.total_transaction_sum @merchant.total_transaction_sum.to_f
end
