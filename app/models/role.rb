class Role < ApplicationRecord
  has_many :role_users, dependent: :destroy
  has_many :users, through: :role_users

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  before_save :downcase_slug_and_name

  private

  def downcase_slug_and_name
    self.slug = slug.downcase
    self.name = name.downcase
  end
end
