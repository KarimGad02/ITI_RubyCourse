# Run the rake task every 5 minutes
every 5.minutes do
  rake "articles:cleanup"
end