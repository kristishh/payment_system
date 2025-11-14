# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "log/cron_log.log"
set :environment, :development

every 1.hour do
  rake 'transactions:destroy_all'
end

# Learn more: http://github.com/javan/whenever
