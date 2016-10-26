class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token #an accessible attribute for random generated token(persistent user;activating user account)
  before_save :downcase_email #before_save is a method reference here that calls downcase_email method first before saving email in database
  #before_save { self.email = email.downcase } #self is used here so that email is not a local variable, but instead available to whole User class not just in before_save method
  before_create :create_activation_digest #before you completely create a user and activated, calling the create method in users_controller.rb, assign an activation token and digest to the database

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Returns the hash digest of the given string. Used for tokens
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

  # Every time you access  and change columns in User database, you always have to authenticate
  # This authenticates the remember, activation, and password reset tokens. Returns true if the given token matches the digest
  def authenticated?(attribute, token) #attribute takes in either remember, activation, password; token is generalized to take in remember_digest token or activation_digest token or password_reset token
    digest = send("#{attribute}_digest") #string interpolation so it can either become remember_digest or activation_digest or password_reset_digest
    return false if digest.nil? #this is evaluated and below code is not if digest variable is empty (ie. no method call for remember_digest using send method)
    BCrypt::Password.new(digest).is_password?(token) #encode token with hash and save into digest
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil) #jsut sets the remember_digest to nil to forget user
  end

  # Activates an account once you click on activation email link
  def activate
    #single call to update_columns, hits database once (Exercise 11.3.3.1)
    update_columns(activated: true, activated_at: Time.zone.now)
    #could also separate the calls but this hits database twice
    #update_attribute(:activated,    true)
    #update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes. Hashes the reset_token and saves to database
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago #invalidate the password reset request if sent link expired earlier than 2 hours ago
  end

  private

    # Converts email to all lower-case. Run by before_save at the top.
    def downcase_email
      email.downcase! #same as self.email = email.downcase
    end

    # Creates and assigns the activation token and digest. Run by before_create at the top
    def create_activation_digest #before user creation completion, assign a token and digest to that user in the database for account activation
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
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
# return keyword ignores anything below that method and thus returns whatever is beside it
# send("#{attribute}_digest") uses send method to lets us call a method with a name of our choice by “sending a message” to a given object (eg. a.send(:length) outputs 3)