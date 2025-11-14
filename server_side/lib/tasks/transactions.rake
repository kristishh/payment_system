namespace :transactions do
  desc "Destroys all transactions"
  task destroy_all: :environment do
    all_transactions = Transaction.destroy_all
    count = all_transactions.count
    all_transactions.destroy_all

    puts "CRON JOB: Successfully destroyed #{count} transactions at #{Time.now}"
  end
end
