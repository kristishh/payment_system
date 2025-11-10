class TransactionsController < ApplicationController
  before_action :set_merchant

  def create
    processor = TransactionProcessor.new(
      merchant: @merchant,
      params: transaction_params
    )
    transaction, errors = processor.process

    if transaction
      render json: transaction, status: :created
    else
      render json: { errors: errors }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Merchant not found for the current user.'] }, status: :not_found
  rescue StandardError => e
    Rails.logger.error "Transaction creation failed unexpectedly: #{e.message}"
    render json: { errors: ['An unexpected server error occurred.'] }, status: :internal_server_error
  end

  private

  def set_merchant
    @merchant = current_user.merchant
    return if @merchant

    raise ActiveRecord::RecordNotFound, 'No active merchant found.'
  end

  def transaction_params
    params.require(:transaction).permit(
      :type,
      :amount,
      :customer_email,
      :customer_phone,
      :status,
      :reference_transaction_id
    )
  end
end
