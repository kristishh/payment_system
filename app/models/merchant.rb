class Merchant < ApplicationRecord
  belongs_to :user

  enum status: { inactive: 0, active: 1 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
