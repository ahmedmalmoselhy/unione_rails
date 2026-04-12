class PasswordResetToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(used: false).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at < ?', Time.current) }

  # Check if token is still valid
  def is_valid?
    !used? && !expired?
  end

  def expired?
    expires_at < Time.current
  end

  # Mark as used
  def use!
    update!(used: true)
  end
end
