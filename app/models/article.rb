class Article < ApplicationRecord
  has_one_attached :image
  belongs_to :user

  # When reports reach a threshold, flag the record for archival
  before_save :flag_for_archive

  private

  def flag_for_archive
    # Treat nil as zero and compare as integer
    if reports_count.to_i >= 3
      self.status = "archived"
      self.is_public = false
    end
  end
end