class ChargeTransaction < Transaction
  validates :reference_transaction, presence: true

  validate :charge_amount_limit, if: :reference_transaction
  validate :reference_must_be_authorize, if: :reference_transaction

  after_commit :approve_parent_transaction, on: :create, if: :approved?
  after_commit :update_merchant_total, on: :create, if: :approved?

  private

  def charge_amount_limit
    return unless amount && reference_transaction && amount > reference_transaction.amount

    errors.add(:amount, 'cannot exceed the referenced Authorize Transaction amount')
    self.status = :error
  end

  def update_merchant_total
    merchant.increment!(:total_transaction_sum, amount)
  end

  def reference_must_be_authorize
    return if reference_transaction.is_a?(AuthorizeTransaction)

    errors.add(:reference_transaction, 'must be an Authorize Transaction')
    self.status = :error
  end

  def approve_parent_transaction
    reference_transaction.update!(status: :approved)
  end
end
