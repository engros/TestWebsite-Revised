class User < ApplicationRecord
  attr_accessor :remember_token #an accessible attribute for random generated token(persistent user)

  before_save { self.email = email.downcase } #self is used here so that email is not a local variable, but instead available to whole User class not just in before_save method
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

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64 #returns a random string with 22 char of 64 possibilities each char
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember #this is also called a user.remember method
    self.remember_token = User.new_token #save the generated token into a class variable called remember_token, accessible in the whole User class with attr_accessor
    update_attribute(:remember_digest, User.digest(remember_token)) #to update the database we use the remember token that has been generated, encrypt it with digest method, then save to database
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token) #note that this remember_token is a local method variable
    return false if remember_digest.nil? #two browser used, logout subtle bug fix
    BCrypt::Password.new(remember_digest).is_password?(remember_token) #compare remember_token with encrypted one in database
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil) #jsut sets the remember_digest to nil to forget user
  end
end


# VALID_EMAIL_REGEX is a constant, ensures that only email addresses that match the pattern will be considered valid.
# regular expression (or regex), which is a powerful (and often cryptic) language for matching patterns in strings.
# uniqueness: { case_sensitive: false } ignores case, i.e., foo@bar.com is treated the same as FOO@BAR.COM or FoO@BAr.coM
# before_save callback to downcase the email attribute before saving the user.
# The only requirement for has_secure_password to work its magic is for the corresponding model to have an attribute called password_digest, encryption is by bcrypt.
# has_secure_password enforces validations on the virtual password and password_confirmation attributes
# User.digest method will encrypt/hash any string (used for password encryption/remember token encryption)
# The urlsafe_base64 method from the SecureRandom module in the Ruby standard library fits the bill:3 it returns a random string of length 22 composed of the characters A–Z, a–z, 0–9, “-”, and “_” (for a total of 64 possibilities, thus “base64”)
# self is reference to User class and is used so that email and remember_token are not treated by Ruby as local method variable, but instead a variable available to the whole User class
# note that self in User model is also used to refer to a user object instance not User class
# to create persistent cookies (expires optionally) it must have: remember token  and user id
# return keyword ignores anything below that method