require 'rails_helper'

RSpec.describe UserCreation do
  subject { described_class.new }

  let(:valid_user_params) { attributes_for(:user) }
  let(:valid_merchant_params) { attributes_for(:merchant).except(:user) }
  let(:invalid_user_params) { attributes_for(:user, email: nil) }
  let(:invalid_merchant_params) { attributes_for(:merchant, name: nil).except(:user) }

  before do
    allow(Rails.logger).to receive(:error)
  end

  describe '#create_user' do
    context 'when creating a non-merchant user (no merchant association)' do
      let(:regular_user_params) { attributes_for(:user, role: 'merchant') }

      it 'creates a user successfully and returns the user object' do
        allow_any_instance_of(User).to receive(:merchant?).and_return(false)

        expect { subject.create_user(user_params: regular_user_params) }
          .to change(User, :count).by(1)

        created_user = User.last
        expect(created_user).to have_attributes(regular_user_params.except(:password, :password_confirmation))
        expect(created_user.merchant).to be_nil
        expect(created_user).to be_a(User)
      end
    end

    context 'when creating a merchant user with valid merchant params' do
      let(:user_params_merchant) { valid_user_params.merge(role: 'merchant') }

      it 'creates both the user and the merchant within a transaction' do
        expect { subject.create_user(user_params: user_params_merchant, merchant_params: valid_merchant_params) }
          .to change(User, :count).by(1)
          .and change(Merchant, :count).by(1)

        created_user = User.last
        expect(created_user).to be_a(User)
        expect(created_user.merchant).to be_present
        expect(created_user.merchant.name).to eq(valid_merchant_params[:name])
      end
    end

    context 'when user validation fails' do
      it 'does not create any records and logs an error' do
        expect { subject.create_user(user_params: invalid_user_params, merchant_params: valid_merchant_params) }
          .to change(User, :count).by(0)
          .and change(Merchant, :count).by(0)

        expect(Rails.logger).to have_received(:error).with(/UserCreator failed for email : Validation failed: Email can't be blank/)
        expect(subject.create_user(user_params: invalid_user_params)).to be_nil
      end
    end

    context 'when merchant validation fails (triggers rollback)' do
      let(:user_params_merchant) { valid_user_params.merge(role: 'merchant') }

      it 'rolls back user creation and logs the ActiveRecord::RecordInvalid error' do
        allow_any_instance_of(Merchant).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Merchant.new))

        expect { subject.create_user(user_params: user_params_merchant, merchant_params: invalid_merchant_params) }
          .to change(User, :count).by(0)
          .and change(Merchant, :count).by(0)

        expect(Rails.logger).to have_received(:error)
        expect(subject.create_user(user_params: user_params_merchant, merchant_params: invalid_merchant_params)).to be_nil
      end
    end

    context 'when an unexpected StandardError occurs' do
      it 'does not create any records and logs the StandardError message' do
        allow_any_instance_of(User).to receive(:save!).and_raise(StandardError, 'Database connection lost')

        expect { subject.create_user(user_params: valid_user_params) }
          .to change(User, :count).by(0)
          .and change(Merchant, :count).by(0)

        expect(Rails.logger).to have_received(:error).with('UserCreator failed unexpectedly: Database connection lost')
        expect(subject.create_user(user_params: valid_user_params)).to be_nil
      end
    end
  end
end
