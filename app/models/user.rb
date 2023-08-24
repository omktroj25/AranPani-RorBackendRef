class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :permissions,autosave:true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: [:admin,:user]
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  accepts_nested_attributes_for :permissions
  def self.authenticate(email, password)
    user = User.find_for_authentication(email: email)
    user&.valid_password?(password) ? user : nil
  end
  def generate_reset_token!
    self.reset_password_token=generate_token
    self.reset_password_sent_at=Time.now.utc
    self.save  
  end
  def reset_password_token_valid?
    (self.reset_password_sent_at + 2.hours) > Time.now.utc
  end
  def reset_password!(new_password)
    self.password=new_password
    self.reset_password_token=nil
    self.save
  end
  def generate_token
    SecureRandom.hex(10)
  end
end
