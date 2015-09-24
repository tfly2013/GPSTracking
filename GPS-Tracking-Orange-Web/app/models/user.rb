class User < ActiveRecord::Base
  acts_as_token_authenticatable
  
  enum role: [:user, :researcher, :admin]
  after_initialize :set_default_role, :if => :new_record?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :trips

  validates :role, inclusion: { in: User.roles.keys }


  def set_default_role
    self.role ||= :user
  end  

  def researcher?
    self.role == :researcher
  end
end
