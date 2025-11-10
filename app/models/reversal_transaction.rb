class ReversalTransaction < Transaction
  validates :amount, absence: true
  validates :reference_transaction, presence: true

  validate :reference_must_be_authorize, if: :reference_transaction
  validate :reference_must_be_approved, if: :reference_transaction

  after_commit :transition_authorize_status, on: :create, if: :approved?
  after_commit :transition_authorize_parent_status_to_reversed, on: :create, if: :approved?

  private

  def transition_authorize_status
    reference_transaction.update!(status: :reversed)
  end

  def reference_must_be_approved
    return if reference_transaction.approved?

    errors.add(:reference_transaction, "can only be reversed if its current status is 'approved'.")
    self.status = :error
  end

  def reference_must_be_authorize
    return if reference_transaction.is_a?(AuthorizeTransaction)

    errors.add(:reference_transaction, 'must be an Authorize Transaction')
    self.status = :error
  end

  def transition_authorize_parent_status_to_reversed
    reference_transaction.update!(status: :reversed)
  end
end
