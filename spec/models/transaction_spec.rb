require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:merchant) { create(:merchant) }
  let(:base_customer_email) { 'customer@test.com' }
  let(:base_customer_phone) { '5551234567' }

  let(:valid_attributes) do
    {
      merchant: merchant,
      amount: 50.00,
      customer_email: base_customer_email,
      customer_phone: base_customer_phone
    }
  end

  subject { AuthorizeTransaction.new(valid_attributes) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without a customer_email' do
      subject.customer_email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:customer_email]).to include("can't be blank")
    end

    it 'is invalid with an improperly formatted customer_email' do
      subject.customer_email = 'bad-email'
      expect(subject).not_to be_valid
      expect(subject.errors[:customer_email]).to include('is invalid')
    end

    it 'is invalid without a customer_phone' do
      subject.customer_phone = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:customer_phone]).to include("can't be blank")
    end

    context 'when amount is required' do
      it 'is invalid with amount <= 0' do
        subject.amount = 0
        expect(subject).not_to be_valid
        expect(subject.errors[:amount]).to include('must be greater than 0')
      end
    end

    context 'UUID validation' do
      it 'generates a valid UUID before creation' do
        subject.uuid = nil
        subject.valid?
        expect(subject.uuid).to match(/\A[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\z/i)
      end
    end

    context 'Customer Consistency Validation (#validate_customer_consistency)' do
      let(:parent_txn) { create(:authorize_transaction, merchant: merchant, customer_email: base_customer_email, customer_phone: base_customer_phone) }

      before do
        subject.reference_transaction = parent_txn
        subject.customer_email = base_customer_email
        subject.customer_phone = base_customer_phone
      end

      it 'is invalid when customer_email does not match the referenced transaction' do
        subject.customer_email = 'new@email.com'
        expect(subject).not_to be_valid
        expect(subject.errors[:customer_email]).to include('must match the email used in the referenced transaction.')
        expect(subject.status).to eq('error')
      end

      it 'is invalid when customer_phone does not match the referenced transaction' do
        subject.customer_phone = '9999999999'
        expect(subject).not_to be_valid
        expect(subject.errors[:customer_phone]).to include('must match the phone number used in the referenced transaction.')
        expect(subject.status).to eq('error')
      end
    end
  end

  describe 'scopes' do
    let!(:approved_txn) { create(:authorize_transaction, status: :approved) }
    let!(:refunded_txn) { create(:authorize_transaction, status: :refunded) }
    let!(:reversed_txn) { create(:authorize_transaction, status: :reversed) }
    let!(:error_txn) { create(:authorize_transaction, status: :error) }

    describe '.approved_or_refunded' do
      it 'includes only approved and refunded transactions' do
        expect(Transaction.approved_or_refunded).to include(approved_txn, refunded_txn)
        expect(Transaction.approved_or_refunded).not_to include(reversed_txn, error_txn)
      end
    end
  end

  describe '#validate_reference_status' do
    let(:charge_txn) { ChargeTransaction.new(valid_attributes) }

    it 'is invalid when referencing a reversed transaction' do
      reversed_authorize = create(:authorize_transaction, status: :reversed)
      charge_txn.reference_transaction = reversed_authorize

      expect(charge_txn).not_to be_valid
      expect(charge_txn.errors[:reference_transaction]).to include('cannot be referenced as it has been reversed')
      expect(charge_txn.status).to eq('error')
    end

    it 'is valid when referencing an approved transaction' do
      approved_authorize = create(:authorize_transaction, status: :approved)
      charge_txn.reference_transaction = approved_authorize
      charge_txn.customer_email = approved_authorize.customer_email
      charge_txn.customer_phone = approved_authorize.customer_phone

      expect(charge_txn).to be_valid
    end

    it 'is valid when referencing a refunded transaction' do
      refunded_authorize = create(:authorize_transaction, status: :refunded)
      charge_txn.reference_transaction = refunded_authorize
      charge_txn.customer_email = refunded_authorize.customer_email
      charge_txn.customer_phone = refunded_authorize.customer_phone

      expect(charge_txn).to be_valid
    end

    context 'when ChargeTransaction is referencing an AuthorizeTransaction with error status' do
      let(:error_authorize) { create(:authorize_transaction, status: :error) }

      it 'is allowed to proceed (to be fixed)' do
        charge_txn.reference_transaction = error_authorize
        charge_txn.customer_email = error_authorize.customer_email
        charge_txn.customer_phone = error_authorize.customer_phone

        expect(charge_txn).to be_valid
      end
    end

    context 'when RefundTransaction references a transaction with error status' do
      let(:error_charge) { create(:charge_transaction, status: :error) }

      let(:refund_attrs) do
        valid_attributes.merge(
          reference_transaction: error_charge,
          type: 'RefundTransaction',
          customer_email: error_charge.customer_email,
          customer_phone: error_charge.customer_phone
        )
      end
      let(:refund_txn) { RefundTransaction.new(refund_attrs) }

      it 'is NOT allowed to proceed' do
        expect(refund_txn).not_to be_valid
        expect(refund_txn.errors[:reference_transaction]).to include('must be approved or refunded to be referenced.')
        expect(refund_txn.status).to eq('error')
      end
    end
  end

  describe '#validate_uniqueness_of_referenced_type' do
    let!(:parent_txn) { create(:authorize_transaction, status: :approved) }

    let(:charge_attrs) do
      valid_attributes.merge(
        reference_transaction: parent_txn,
        type: 'ChargeTransaction',
        customer_email: parent_txn.customer_email,
        customer_phone: parent_txn.customer_phone
      )
    end

    context 'when a duplicate approved transaction of the same type exists' do
      let!(:existing_duplicate) { create(:charge_transaction, charge_attrs) }

      subject { ChargeTransaction.new(charge_attrs) }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include('Charge Transaction for this reference has already been approved.')
        expect(subject.status).to eq('error')
      end

      it 'is valid when the duplicate is not approved' do
        existing_duplicate.update_column(:status, :error)

        expect(subject).to be_valid
      end

      it 'is valid for an update (excluding self)' do
        existing_duplicate.amount = 60.00
        expect(existing_duplicate).to be_valid
      end
    end
  end
end
