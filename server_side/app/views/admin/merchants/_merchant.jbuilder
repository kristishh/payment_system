json.extract! merchant.user,
              :email
json.extract! merchant,
              :id,
              :name,
              :description,
              :status
json.total_transaction_sum merchant.total_transaction_sum.to_f
