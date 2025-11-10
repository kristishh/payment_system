class TransactionProcessor
  def initialize(merchant:, params:)
    @merchant = merchant
    @params = params
    @type_string = params[:type].to_s.downcase
  end

  def process
    transaction_class = determine_transaction_class

    return [nil, ['Invalid transaction type specified.']] unless transaction_class

    transaction = transaction_class.new(@params.except(:type))
    transaction.merchant = @merchant
    if transaction.save
      [transaction, []]
    else
      [nil, transaction.errors.full_messages]
    end
  end

  private

  def determine_transaction_class
    mapping = {
      'authorize' => AuthorizeTransaction,
      'charge' => ChargeTransaction,
      'refund' => RefundTransaction,
      'reversal' => ReversalTransaction
    }
    mapping[@type_string]
  end
end
