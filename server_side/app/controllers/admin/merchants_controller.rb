class Admin::MerchantsController < ApplicationController
  before_action :authorize_user!
  before_action :set_merchant, only: %i[update destroy]

  def index
    @merchants = Merchant.includes(:user).all

    render :index
  end

  def update
    @merchant.update!(merchant_params.slice(:name, :description, :status))
    render :show
  rescue StandardError => e
    render status: :bad_request, json: { error: e.message }
  end

  def destroy
    @merchant.destroy!
  rescue ActiveRecord::RecordNotDestroyed => e
    render status: :bad_request, json: { error: e.message }
  end

  private

  def set_merchant
    @merchant = Merchant.find(params[:id])
  rescue StandardError => e
    render status: :bad_request, json: { error: e.message }
  end

  def merchant_params
    params.require(:merchant).permit \
      :email,
      :name,
      :description,
      :status,
      :total_transaction_sum
  end
end
