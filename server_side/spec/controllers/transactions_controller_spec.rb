require 'rails_helper'

RSpec.describe TransactionsController, type: :request do
  let!(:merchant) { create(:merchant) }
  let!(:user) { merchant.user }
  let(:transaction_processor) { instance_double(TransactionProcessor) }
  let(:json_headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }
  let(:transaction_data) do
    {
      type: 'authorize',
      amount: 100.00,
      customer_email: 'test@example.com',
      customer_phone: '1234567890',
      reference_transaction_id: nil
    }
  end
  let(:transaction_params) do
    { transaction: transaction_data }
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow(TransactionProcessor).to receive(:new).and_return(transaction_processor)
  end

  shared_context 'authenticated user with merchant' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow(user).to receive(:merchant).and_return(merchant)
    end
  end

  describe 'POST #create' do
    let(:url) { '/transactions' }

    context 'when transaction creation is successful' do
      include_context 'authenticated user with merchant'

      let(:successful_transaction) { instance_double(Transaction, status: 'approved', amount: 100.00, type: 'AuthorizeTransaction', to_json: { id: SecureRandom.uuid, status: 'approved' }.to_json) }

      before do
        allow(transaction_processor).to receive(:process).and_return([successful_transaction, []])
      end

      it 'returns 201 created status' do
        post url, params: transaction_params, as: :json
        expect(response).to have_http_status(:created)
      end

      it 'renders the created transaction as JSON' do
        post url, params: transaction_params, as: :json
        expect(response.body).to eq(successful_transaction.to_json)
      end
    end

    context 'when transaction creation fails validation' do
      include_context 'authenticated user with merchant'

      let(:validation_errors) { ['Amount cannot be zero', 'Customer email is invalid'] }
      let(:expected_json) { { errors: validation_errors }.to_json }

      before do
        allow(transaction_processor).to receive(:process).and_return([nil, validation_errors])
      end

      it 'returns 422 unprocessable_entity status' do
        post url, params: transaction_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders validation errors as JSON' do
        post url, params: transaction_params, as: :json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when the user is not authenticated' do
      let(:expected_json) { { errors: ['An unexpected server error occurred.'] }.to_json }

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end
    end

    context 'when the merchant is not found (before_action failure)' do
      let(:expected_json) { { errors: ['Merchant not found for the current user.'] }.to_json }

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        allow(user).to receive(:merchant).and_return(nil)
      end

      it 'returns 404 not_found status' do
        post url, params: transaction_params, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when an unexpected StandardError occurs during processing' do
      include_context 'authenticated user with merchant'

      let(:expected_json) { { errors: ['An unexpected server error occurred.'] }.to_json }

      before do
        allow(transaction_processor).to receive(:process).and_raise(StandardError.new('Database unavailable'))
      end

      it 'returns 500 internal_server_error status' do
        post url, params: transaction_params, as: :json
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'renders a generic server error message' do
        post url, params: transaction_params, as: :json
        expect(response.body).to include('An unexpected server error occurred.')
      end
    end

    context 'parameter handling' do
      include_context 'authenticated user with merchant'

      let(:extra_params) { transaction_params.deep_merge(transaction: { extra_key: 'ignored' }) }

      it 'only passes permitted parameters to the TransactionProcessor' do
        expected_params_hash = transaction_data.stringify_keys.with_indifferent_access

        expect(TransactionProcessor).to receive(:new).with(
          merchant: merchant,
          params: hash_including(expected_params_hash)
        ).and_return(transaction_processor)

        allow(transaction_processor).to receive(:process).and_return([double, []])

        post url, params: extra_params, as: :json
      end
    end
  end
end
