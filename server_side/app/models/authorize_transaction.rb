class AuthorizeTransaction < Transaction
  validates :reference_transaction, absence: true
end
