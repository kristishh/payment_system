json.merchants do
  json.array! @merchants, partial: 'admin/merchants/merchant', as: :merchant
end
