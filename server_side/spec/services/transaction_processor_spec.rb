require 'rails_helper'

RSpec.describe TransactionProcessor, type: :service do
  let(:merchant) { create(:merchant) }
  let(:base_params) do
    {
      type: 'authorize',
      amount: 100.00,
      customer_email: 'test@example.com',
      extra_param: 'should_be_ignored'
    }.with_indifferent_access
  end

  let(:transaction_instance) do
    instance_double(AuthorizeTransaction, merchant: merchant, errors: double(full_messages: ['Error message']), amount: 100.00)
  end

  subject { described_class.new(merchant: merchant, params: base_params) }

  def stub_transaction_creation(transaction_class, save_result:, errors: nil)
    allow(subject).to receive(:determine_transaction_class).and_return(transaction_class)

    expected_params = base_params.except(:type)

    allow(transaction_class).to receive(:new).with(hash_including(expected_params)).and_return(transaction_instance)
    allow(transaction_instance).to receive(:merchant=).with(merchant)
    allow(transaction_instance).to receive(:save).and_return(save_result)

    return unless errors

    allow(transaction_instance.errors).to receive(:full_messages).and_return(errors)
  end

  describe '#process' do
    context 'when a valid transaction type is provided' do
      let(:transaction_class) { AuthorizeTransaction }

      before do
        base_params[:type] = 'authorize'
      end

      it 'correctly determines the STI class' do
        expect(subject.send(:determine_transaction_class)).to eq(AuthorizeTransaction)
      end

      it 'initializes the correct transaction type with filtered parameters' do
        stub_transaction_creation(transaction_class, save_result: true)

        expect(transaction_class).to receive(:new).with(hash_excluding(:type)).and_return(transaction_instance)

        subject.process
      end

      it 'assigns the merchant to the new transaction' do
        stub_transaction_creation(transaction_class, save_result: true)

        expect(transaction_instance).to receive(:merchant=).with(merchant)

        subject.process
      end

      context 'and saving is successful' do
        before do
          stub_transaction_creation(transaction_class, save_result: true)
        end

        it 'returns the transaction and an empty error array' do
          transaction, errors = subject.process
          expect(transaction).to eq(transaction_instance)
          expect(errors).to be_empty
        end
      end

      context 'and saving fails due to validation' do
        let(:validation_errors) { ['Amount is too low'] }

        before do
          stub_transaction_creation(transaction_class, save_result: false, errors: validation_errors)
        end

        it 'returns nil and the transaction full error messages' do
          transaction, errors = subject.process
          expect(transaction).to be_nil
          expect(errors).to eq(validation_errors)
        end
      end
    end

    context 'when an invalid transaction type is provided' do
      before do
        base_params[:type] = 'unknown_type'
      end

      it 'returns nil and an "Invalid transaction type specified." error message' do
        transaction, errors = subject.process
        expect(transaction).to be_nil
        expect(errors).to eq(['Invalid transaction type specified.'])
      end
    end

    context 'when checking all valid transaction types' do
      it 'maps "authorize" to AuthorizeTransaction' do
        base_params[:type] = 'authorize'
        expect(subject.send(:determine_transaction_class)).to eq(AuthorizeTransaction)
      end

      it 'maps "charge" to ChargeTransaction' do
        base_params[:type] = 'charge'
        expect(subject.send(:determine_transaction_class)).to eq(ChargeTransaction)
      end

      it 'maps "refund" to RefundTransaction' do
        base_params[:type] = 'refund'
        expect(subject.send(:determine_transaction_class)).to eq(RefundTransaction)
      end

      it 'maps "reversal" to ReversalTransaction' do
        base_params[:type] = 'reversal'
        expect(subject.send(:determine_transaction_class)).to eq(ReversalTransaction)
      end
    end
  end
end
