class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end

# VALID_EMAIL_REGEX is a constant, ensures that only email addresses that match the pattern will be considered valid.
# regular expression (or regex), which is a powerful (and often cryptic) language for matching patterns in strings.
# uniqueness: { case_sensitive: false } ignores case, i.e., foo@bar.com is treated the same as FOO@BAR.COM or FoO@BAr.coM
# before_save callback to downcase the email attribute before saving the user.
# The only requirement for has_secure_password to work its magic is for the corresponding model to have an attribute called password_digest, encryption is by bcrypt.
# has_secure_password enforces validations on the virtual password and password_confirmation attributes