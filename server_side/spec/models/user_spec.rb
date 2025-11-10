require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }

  describe 'Devise Configuration' do
    it 'includes the JTIMatcher revocation strategy' do
      expect(described_class.included_modules).to include(Devise::JWT::RevocationStrategies::JTIMatcher)
    end

    it 'is set up for database, validatable, registerable, and JWT authentication' do
      expect(Devise.mappings[:user].modules).to include(:database_authenticatable, :validatable, :registerable, :jwt_authenticatable)
    end
  end

  describe 'Associations' do
    it { is_expected.to have_one(:merchant).dependent(:destroy) }

    it 'destroys the associated merchant when the user is destroyed' do
      merchant = create(:merchant, user: user)
      expect { user.destroy }.to change(Merchant, :count).by(-1)
      expect(Merchant.find_by(id: merchant.id)).to be_nil
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it 'is valid with a properly formatted email' do
      user.email = 'test@example.com'
      expect(user).to be_valid
    end

    it 'is invalid with a badly formatted email' do
      user.email = 'invalid-email'
      expect(user).to be_invalid
      expect(user.errors[:email]).to include('must be a valid email address')
    end
  end

  describe 'Role and Callbacks' do
    context 'when a new user is initialized' do
      let(:new_user) { build(:user) }

      it 'sets the role to merchant by default' do
        expect(new_user.role).to eq('merchant')
        expect(new_user).to be_merchant
      end

      it 'allows the role to be set to admin' do
        new_user.role = :admin
        expect(new_user).to be_admin
      end

      it 'responds to all defined roles' do
        expect(described_class.roles.keys).to match_array(%w[merchant admin])
      end
    end
  end

  describe 'Included Helpers' do
    it 'includes ActionView::Helpers::NumberHelper' do
      expect(described_class.included_modules).to include(ActionView::Helpers::NumberHelper)
    end
  end
end
