class UserCreation
  def create_user(user_params:, merchant_params: {})
    @user = User.new(user_params)

    ActiveRecord::Base.transaction do
      @user.save!

      if @user.merchant? && merchant_params.present?
        merchant = @user.build_merchant(
          name: merchant_params[:name],
          description: merchant_params[:description],
          status: :active,
          total_transaction_sum: 0,
        )
        @user.merchant.update!(merchant_params)
        merchant.assign_attributes(merchant_params)

        merchant.save!
      end

      @user
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "UserCreator failed for email #{user_params[:email]}: #{e.message}"
  rescue StandardError => e
    Rails.logger.error "UserCreator failed unexpectedly: #{e.message}"
  end
end
