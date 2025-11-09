class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ActionView::Helpers::NumberHelper

  devise :database_authenticatable,
    :validatable,
    :registerable,
    :jwt_authenticatable,
    jwt_revocation_strategy: self

  after_initialize :set_default_role, if: :new_record?

  enum :role, { merchant: 0, admin: 1 }

  has_one :merchant, dependent: :destroy

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, presence: true, uniqueness: { case_sensitive: false }

  private

  def set_default_role
    self.role ||= :merchant
  end
end
