class Transaction < ApplicationRecord
  belongs_to :merchant
  belongs_to :reference_transaction, class_name: 'Transaction', optional: true

  self.primary_key = 'id'

  alias_attribute :uuid, :id

  enum :status, { approved: 0, reversed: 1, refunded: 2, error: 3 }

  validates :uuid, presence: true, uniqueness: true, format: { with: /\A[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\z/i, message: 'is not a valid UUID format' }
  validates :amount, presence: true, numericality: { greater_than: 0 }, unless: -> { type == 'ReversalTransaction' }
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :customer_phone, presence: true
  validates :status, presence: true

  validate :validate_active_merchant, on: :create
  validate :validate_reference_status, if: :reference_transaction
  validate :validate_customer_consistency, if: :reference_transaction
  validate :validate_uniqueness_of_referenced_type,
           if: -> { reference_transaction_id.present? }

  before_validation :generate_uuid, on: :create
  before_validation :set_default_status, on: :create

  scope :approved_or_refunded, -> { where(status: %i[approved refunded]) }

  private

  def set_default_status
    self.status ||= :error
  end

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def validate_reference_status
    return unless reference_transaction

    is_charge_fixing_authorize = is_a?(ChargeTransaction) && reference_transaction.is_a?(AuthorizeTransaction)
    acceptable_status = reference_transaction.approved? || reference_transaction.refunded?

    if is_charge_fixing_authorize && reference_transaction.error?
    elsif reference_transaction.reversed?
      errors.add(:reference_transaction, 'cannot be referenced as it has been reversed')
      self.status = :error
    elsif !acceptable_status
      errors.add(:reference_transaction, 'must be approved or refunded to be referenced.')
      self.status = :error
    end
  end

  def validate_active_merchant
    return unless merchant && !merchant.active?

    errors.add(:merchant, 'must be active to process transactions')
    self.status = :error
  end

  def validate_uniqueness_of_referenced_type
    return unless reference_transaction_id.present?

    duplicate_query = Transaction.where(
      reference_transaction_id: reference_transaction_id,
      type: type,
      status: :approved
    )

    duplicate_query = duplicate_query.where.not(id: id)

    return unless duplicate_query.exists?

    errors.add(:base, "#{type.titleize} for this reference has already been approved.")
    self.status = :error
  end

  def validate_customer_consistency
    return unless reference_transaction

    if customer_email.present? && reference_transaction.customer_email.present? && customer_email != reference_transaction.customer_email
      errors.add(:customer_email, 'must match the email used in the referenced transaction.')
      self.status = :error
    end

    return unless customer_phone.present? && reference_transaction.customer_phone.present? && customer_phone != reference_transaction.customer_phone

    errors.add(:customer_phone, 'must match the phone number used in the referenced transaction.')
    self.status = :error
  end
end
