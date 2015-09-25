# include Warden::Test::Helpers

module RequestMacros
	
	def login_user
        @request.env["devise.mapping"] = Devise.mappings[:user]
        user = User.create(:email => "userkaiqi@test.com", :password => "abc123456",:role => 0)
        sign_in user
        user
	end

        def login_researcher
        @request.env["devise.mapping"] = Devise.mappings[:user]
        user = User.create(:email => "reseakaiqi@test.com", :password => "abc123456",:role => 1)
        sign_in user
        user
        end

        def login_admin
        @request.env["devise.mapping"] = Devise.mappings[:user]
        user = User.create(:email => "adminkaiqi@test.com", :password => "abc123456",:role => 2)
        sign_in user
        user
        end

        def build_user
        @request.env["devise.mapping"] = Devise.mappings[:user]
        user = User.create(:email => "kaiqi@test.com", :password => "abc123456")
        user
        end

        def build_many_user
        @request.env["devise.mapping"] = Devise.mappings[:user]
        User.create(:email => "kaiqi0@test.com", :password => "abc123456")
        User.create(:email => "kaiqi1@test.com", :password => "abc123456")
        User.create(:email => "kaiqi2@test.com", :password => "abc123456")
        User.create(:email => "kaiqi3@test.com", :password => "abc123456")
        end

        def build_trip (userid)
                @request.headers["Accept"] = "application/json"
                @request.env["CONTENT_TYPE"] = "application/json"
                server_response = post :create , 
                {  format: :json,
                :locations =>  [ 
                
                  {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456867 },
                  {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456868 },
                  {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456869 },
                  {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456860 },
                                ]
                }, as: :json
                json = JSON.parse server_response.body
                trip=Trip.find_by(user: userid)
        end

# def locations_array
#   params.permit(:locations => [:latitude, :longitude,:speed,:accuracy,:time]).require(:locations)
# end
# class Location < ActiveRecord::Base
#   belongs_to :segment
#   validates :latitude, :inclusion => -90..90, presence: true
#   validates :longitude, :inclusion => -180..180, presence: true
# end


end