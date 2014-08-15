class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
    belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
    has_many :referrals, :class_name => "User", :foreign_key => "referrer_id"
    has_many :friends
    
    #attr_accessible :email

    validates :email, :uniqueness => true, :format => { :with => /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i, :message => "Invalid email format." }
    validates :referral_code, :uniqueness => true

    before_create :create_referral_code
    after_create :send_welcome_email

    REFERRAL_STEPS = [
        {
            'count' => 5,
            "html" => "Early Invitation to<br>events",
            "class" => "two",
            # "image" =>  ActionController::Base.helpers.asset_path("refer/cream-tooltip@2x.png")
        },
        {
            'count' => 10,
            "html" => "Discount Entry to<br>One Event",
            "class" => "three",
            # "image" => ActionController::Base.helpers.asset_path("refer/truman@2x.png")
        },
        # {
        #     'count' => 25,
        #     "html" => "Discount Entry to Every<br>Event for One Year",
        #     "class" => "four",
        #     "image" => ActionController::Base.helpers.asset_path("refer/winston@2x.png")
        # },
        # {
        #     'count' => 50,
        #     "html" => "Free Entry to 5<br>Events this year",
        #     "class" => "five",
        #     "image" => ActionController::Base.helpers.asset_path("refer/blade-explain@2x.png")
        # }
    ]

    private

    def create_referral_code
        referral_code = SecureRandom.hex(5)
        @collision = User.find_by_referral_code(referral_code)

        while !@collision.nil?
            referral_code = SecureRandom.hex(5)
            @collision = User.find_by_referral_code(referral_code)
        end

        self.referral_code = referral_code
    end

    def send_welcome_email
        UserMailer.delay.signup_email(self)
    end
end
