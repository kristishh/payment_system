json.transactions do
  json.array! @transactions, partial: 'transaction', as: :transaction, is_root: true
end
