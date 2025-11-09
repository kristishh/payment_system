require 'rails_helper'

RSpec.describe Merchant, type: :model do
  let(:user) { create(:user) }
  let(:merchant) { create(:merchant, user: user) }

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Validations' do
    context 'when validating name' do
      it { is_expected.to validate_presence_of(:name) }

      it 'is invalid without a name' do
        invalid_merchant = build(:merchant, name: nil)
        expect(invalid_merchant).to be_invalid
        expect(invalid_merchant.errors[:name]).to include("can't be blank")
      end
    end
  end

  describe 'Enums and Callbacks' do
    it 'responds to the defined statuses' do
      expect(described_class.statuses.keys).to match_array(%w[inactive active])
    end

    context 'when a new merchant is initialized' do
      let(:new_merchant) { build(:merchant) }

      it 'sets the status to active by default' do
        expect(new_merchant.status).to eq('active')
        expect(new_merchant).to be_active
      end

      it 'retains an explicitly set status' do
        inactive_merchant = build(:merchant, :inactive)
        expect(inactive_merchant).to be_inactive
      end
    end
  end
end
