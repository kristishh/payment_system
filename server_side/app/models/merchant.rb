class Merchant < ApplicationRecord
  belongs_to :user, dependent: :destroy

  has_many :transactions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :total_transaction_sum, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_default_status, if: :new_record?

  enum :status, { inactive: 0, active: 1 }

  private

  def destroy_user
    user.destroy!
  end

  def set_default_status
    self.status ||= :active
  end
end
