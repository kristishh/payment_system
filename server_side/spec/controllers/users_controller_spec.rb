require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:admin_user) { create(:user, role: 'admin') }
  let(:merchant_user) { create(:user, role: 'merchant', email: 'seconduser@gmail.com') }
  let!(:merchant_record) { create(:merchant, user: merchant_user) }

  describe 'GET #index' do
    context 'when the current user is an admin' do
      before do
        sign_in admin_user

        get :index, format: :json
      end

      it 'returns an HTTP success status (200)' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the current user is a merchant user' do
      before do
        sign_in merchant_user

        get :index, format: :json
      end

      it 'returns an HTTP success status (200)' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
