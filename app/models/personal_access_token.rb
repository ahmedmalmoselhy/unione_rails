class PersonalAccessToken < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }
  scope :revoked, -> { where.not(revoked_at: nil) }
  scope :expired, -> { where('expires_at < ?', Time.current) }

  # Revoke this token
  def revoke!
    update!(revoked_at: Time.current)
  end

  # Check if token is valid (not revoked and not expired)
  def is_valid?
    !revoked? && !expired?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  # Record usage
  def touch_usage!
    update!(last_used_at: Time.current)
  end
end
