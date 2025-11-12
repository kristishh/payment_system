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
end
