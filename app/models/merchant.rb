class Merchant < ApplicationRecord
  belongs_to :user

  enum :status, { inactive: 0, active: 1 }

  validates :name, presence: true

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= :active
  end
end
