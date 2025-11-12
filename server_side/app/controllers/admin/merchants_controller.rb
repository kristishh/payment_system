class Admin::MerchantsController < ApplicationController
  before_action :authorize_user!

  def index
    @merchants = Merchant.includes(:user).all

    render :index
  end
end
