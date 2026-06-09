class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.boolean :is_public
      t.integer :reports_count
      t.string :default
      t.string :0
      t.string :status

      t.timestamps
    end
  end
end
