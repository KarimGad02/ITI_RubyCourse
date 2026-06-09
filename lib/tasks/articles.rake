namespace :articles do
  desc "Remove articles that have been reported 6 or more times"
  task cleanup: :environment do
    # Simple query to find and destroy bad articles
    bad_articles = Article.where("reports_count >= ?", 6)
    count = bad_articles.count
    bad_articles.destroy_all
    
    puts "Deleted #{count} highly reported articles."
  end
end