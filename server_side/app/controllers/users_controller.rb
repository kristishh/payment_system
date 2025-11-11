class UsersController < ApplicationController
  def index
    @user = current_user

    @user = User.includes(:merchant).find(@user.id) if @user.role == 'merchant'

    render :index
  end
end
