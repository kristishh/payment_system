json.id transaction.id
json.customer_email transaction.customer_email if is_root == true
json.customer_phone transaction.customer_phone if is_root == true
json.amount transaction.amount
json.status transaction.status
json.type transaction.type
json.created_at transaction.created_at

if transaction.referenced_transactions.any?
  json.referenced_transactions do
    json.array! transaction.referenced_transactions do |referenced_transaction|
      json.partial! 'transactions/transaction', transaction: referenced_transaction, is_root: false
    end
  end
end
