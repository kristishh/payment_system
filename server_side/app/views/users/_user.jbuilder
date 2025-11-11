json.extract! user,
              :id,
              :email,
              :role

if user.role == 'merchant' && user.merchant.present?
  json.merchant do
    json.partial! 'merchants/merchant', merchant: user.merchant
  end
end
