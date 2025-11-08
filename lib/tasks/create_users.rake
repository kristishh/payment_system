require 'csv'

namespace :users do
  desc "creates users, both admin and merchant"
  task create_users: :environment do
    file_path = Rails.root.join('db/seeds', 'users.csv')
    success_count = 0
    failure_count = 0
    user_creator = UserCreation.new

    CSV.foreach(file_path, headers: true, external_encoding: 'UTF-8') do |row|
      data = row.to_h.symbolize_keys
      user_params = {
        email: data[:email],
        password: data[:password],
        role: data[:role],
      }
      merchant_params = {}

      if data[:role] == 'merchant'
        merchant_params = {
          name: data[:merchant_name],
          description: data[:merchant_description],
          status: :active,
        }
      end

      created_user = user_creator.create_user(
        user_params: user_params,
        merchant_params: merchant_params,
      )

      created_user ? success_count += 1 : failure_count += 1
    end

    puts "Summary: #{success_count} successful, #{failure_count} failed."
  end
end
