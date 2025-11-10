class RefundTransaction < Transaction
  validates :reference_transaction, presence: true

  validate :refund_amount_limit, if: :reference_transaction

  after_commit :transition_charge_status, on: :create, if: :approved?

  # Hooks to update merchant's total sum
  after_commit :decrease_merchant_total, on: :create, if: :approved?
  after_commit :transition_authorize_parent_status_to_refunded, on: :create, if: :approved?

  private

  def refund_amount_limit
    return unless amount && reference_transaction && amount != reference_transaction.amount

    errors.add(:amount, 'must be equal to the referenced Charge Transaction amount for a full refund')
    self.status = :error
  end

  def transition_charge_status
    reference_transaction.update!(status: :refunded)
  end

  def decrease_merchant_total
    merchant.decrement!(:total_transaction_sum, amount)
  end

  def transition_authorize_parent_status_to_refunded
    authorize_transaction = reference_transaction.reference_transaction

    return unless authorize_transaction&.is_a?(AuthorizeTransaction)

    authorize_transaction.update!(status: :refunded)
  end
end
