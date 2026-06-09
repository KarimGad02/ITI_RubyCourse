json.extract! article, :id, :title, :body, :user_id, :is_public, :reports_count, :default, :0, :status, :created_at, :updated_at
json.url article_url(article, format: :json)
