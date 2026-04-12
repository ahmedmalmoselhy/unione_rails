class User < ApplicationRecord
  has_secure_password validations: true

  has_many :role_users, dependent: :destroy
  has_many :roles, through: :role_users
  has_many :personal_access_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6, allow_nil: true },
                       confirmation: true
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }

  before_save :downcase_email

  scope :active, -> { where(is_active: true) }
  scope :with_role, ->(role_slug) { joins(:roles).where(roles: { slug: role_slug }) }

  # Assign a role to the user
  def assign_role(role)
    role_obj = Role.find_by(slug: role) || Role.find_by(name: role)
    return false unless role_obj
    roles << role_obj unless roles.include?(role_obj)
    true
  end

  # Check if user has a specific role
  def has_role?(role_slug)
    roles.exists?(slug: role_slug)
  end

  # Check if user is admin
  def admin?
    has_role?('admin')
  end

  # Check if user is student
  def student?
    has_role?('student')
  end

  # Check if user is professor
  def professor?
    has_role?('professor')
  end

  # Get all role slugs
  def role_slugs
    roles.pluck(:slug)
  end

  # Full name
  def full_name
    "#{first_name} #{last_name}"
  end

  # Generate password reset token
  def generate_password_reset_token(ip_address = nil, user_agent = nil)
    password_reset_tokens.create!(
      token: SecureRandom.urlsafe_base64(32),
      expires_at: 1.hour.from_now,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  # Create a personal access token
  def create_token(name: 'API Token', expires_in: 7.days, ip_address: nil, user_agent: nil)
    token_string = SecureRandom.urlsafe_base64(32)
    personal_access_tokens.create!(
      name: name,
      token: Digest::SHA256.hexdigest(token_string),
      expires_at: expires_in.from_now,
      ip_address: ip_address,
      user_agent: user_agent
    )
    token_string
  end

  private

  def downcase_email
    self.email = email.downcase if email
  end
end
