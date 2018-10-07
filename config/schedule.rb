set :output, "#{RAILS_ROOT}/log/cron_log.log"
set :environment, 'production'

every 1.day, :at => "5:29am" do
  runner "Schedule::Cleaner.clean"
end

every 1.day, :at => "0:01am" do
  runner "Schedule::DragonPlanner.plan_arrival"
end

# in this task we can distribute money.
# so we should perform all money distribution jobs in one batch
every 5.minutes do
  runner "Schedule::All.check"
end

every 1.day, :at => "3:07" do
  runner "Schedule::ReferenceBonus.distribute"
end