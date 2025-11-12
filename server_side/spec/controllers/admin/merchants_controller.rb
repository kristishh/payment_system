require 'rails_helper'

RSpec.describe Admin::MerchantsController, type: :controller do
  let!(:user1) { create(:user, :admin, email: 'user1@example.com') }
  let!(:user2) { create(:user, :admin, email: 'user2@example.com') }
  let!(:merchant1) { create(:merchant, name: 'Alpha Merchant', user: user1) }
  let!(:merchant2) { create(:merchant, name: 'Beta Merchant', user: user2) }

  it { is_expected.to use_before_action(:authorize_user!) }

  describe 'GET #index' do
    before do
      allow(Merchant).to receive(:includes).and_call_original
    end

    context 'when the request is authorized' do
      before do
        sign_in user1
        allow(controller).to receive(:authorize_user!).and_return(true)
        get :index
      end

      it 'loads all merchants and assigns them to @merchants' do
        expected_merchants = [merchant1, merchant2]
        expect(assigns(:merchants)).to match_array(expected_merchants)
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end

      it 'uses includes(:user) for eager loading to prevent N+1 queries' do
        expect(Merchant).to have_received(:includes).with(:user)
      end
    end

    context 'when the request is unauthorized' do
      it 'does not assign merchants' do
        expect(assigns(:merchants)).to be_nil
        get :index
      end
    end
  end

  describe 'PUT #update' do
    let(:valid_params) do
      { id: merchant1.id, merchant: { name: 'New Name', status: 'active', total_transaction_sum: 999.99 } }
    end
    let(:invalid_params) do
      { id: merchant1.id, merchant: { name: '', description: 'test', status: 'active' } }
    end

    before do
      sign_in user1
      allow(controller).to receive(:authorize_user!).and_return(true)
    end

    context 'with valid parameters' do
      it 'updates the requested merchant attributes' do
        put :update, params: valid_params, format: :json
        merchant1.reload

        expect(merchant1.name).to eq('New Name')
        expect(merchant1.status).to eq('active')
        expect(merchant1.total_transaction_sum).to_not eq(999.99)
      end

      it 'returns a 200 OK status' do
        put :update, params: valid_params, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'renders the show template' do
        expect(put(:update, params: valid_params, format: :json)).to render_template(:show)
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(Merchant).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(merchant1))
      end

      it 'does not update the merchant' do
        expect do
          put :update, params: invalid_params, format: :json
        end.to_not(change { merchant1.reload.name })
      end

      it 'returns a 400 Bad Request status ' do
        put :update, params: invalid_params, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        put :update, params: invalid_params, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('Validation failed')
      end
    end

    context 'when merchant is not found' do
      it 'returns a 400 Bad Request status' do
        put :update, params: { id: 999_999, merchant: { name: 'Test' } }, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a not found error message' do
        put :update, params: { id: 999_999, merchant: { name: 'Test' } }, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include("Couldn't find Merchant")
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in user1
      allow(controller).to receive(:authorize_user!).and_return(true)
    end

    context 'when merchant is successfully destroyed' do
      let!(:temp_user) { create(:user, :admin, email: 'temp@example.com') }
      let!(:temp_merchant) { create(:merchant, name: 'Temp Merchant', user: temp_user) }

      it 'destroys the requested merchant' do
        expect do
          delete :destroy, params: { id: temp_merchant.id }, format: :json
        end.to change(Merchant, :count).by(-1)
      end

      it 'returns a 204 No Content status' do
        delete :destroy, params: { id: temp_merchant.id }, format: :json
        expect(response).to have_http_status(:no_content) # 204
      end
    end

    context 'when merchant destruction fails' do
      let!(:temp_user) { create(:user, :admin, email: 'temp@example.com') }
      let!(:temp_merchant) { create(:merchant, name: 'Temp Merchant', user: temp_user) }

      before do
        allow_any_instance_of(Merchant).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new('Failed to destroy'))
      end

      it 'does not change the merchant count and returns bad_request error' do
        expect do
          delete :destroy, params: { id: temp_merchant.id }, format: :json
        end.to_not change(Merchant, :count)

        delete :destroy, params: { id: temp_merchant.id }, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
