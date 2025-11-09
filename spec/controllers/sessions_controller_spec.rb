require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let!(:user) { create(:user, :merchant) }

    context 'when login is successful' do
      it 'returns a successful response with the user data' do
        post :create, params: { user: { email: user.email, password: user.password } }, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']['code']).to eq(200)
        expect(JSON.parse(response.body)['status']['message']).to eq('Logged in successfully.')
        expect(JSON.parse(response.body)['status']['data']['user']['id']).to eq(user.id)
      end
    end

    context 'when login fails' do
      it 'returns an unauthorized response' do
        post :create, params: { user: { email: user.email, password: 'wrong_password' } }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user, :merchant) }

    context 'when logout is successful' do
      it 'returns a successful logout response' do
        sign_in user
        token = JWT.encode({ sub: user.id }, Rails.application.credentials.fetch(:secret_key_base))
        @request.headers['Authorization'] = "Bearer #{token}"

        delete :destroy, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq(200)
        expect(JSON.parse(response.body)['message']).to eq('Logged out successfully.')
      end
    end

    context 'when no active session is found' do
      let!(:user) { create(:user, :merchant) }

      it 'returns an unauthorized response' do
        @request.headers['Authorization'] = 'Bearer invalid.token'

        delete :destroy, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['status']).to eq(401)
        expect(JSON.parse(response.body)['message']).to eq("Couldn't find an active session.")
      end
    end
  end
end
