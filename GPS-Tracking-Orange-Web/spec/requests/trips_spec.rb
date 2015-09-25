# require 'rails_helper'

# RSpec.describe "Trips", type: :request do
#   describe "GET /trips" do
#     it "works! (now write some real specs)" do
#       get trips_path
#       expect(response).to have_http_status(302)
#     end
#   end


#   # describe "GET #index" do
#   #   it "sign in as user get all trips as @trips" do
#   #     @request.headers["Accept"] = "application/json"
#   #     @request.env["CONTENT_TYPE"] = "application/json"
#   #     user=login_user
#   #     trip = Trip.find_by(user: user.id)
#   #     # get :index, {}, valid_session
#   #     expect(assigns(:trips)).to eq(trip)
#   #   end
#   # end

#   describe "GET #show" do
#     it "assigns the requested trip as @trip" do
#       user = login_user
#             # expect(user.id).to eq(1)
#       my_trip = build_trip(user.id)
#       # server_response = get "/trips/#{my_trip.id}"
#        # server_response = get "/trips/new"
#       # server_response = get :show, {:id => my_trip.id}
#       expect(:get => "/trips/#{my_trip.id}").to route_to("trips#show", :id => "#{my_trip.id}")
#       expect(response).to have_http_status(200)
#       expect(response).to be_success
#       expect(assigns(:trip)).to eq(my_trip)

#     end
#   end

#   # describe "GET #new" do
#   #   it "assigns a new trip as @trip" do
#   #     get :new, {}, valid_session
#   #     expect(assigns(:trip)).to be_a_new(Trip)
#   #   end
#   # end

#   describe "GET #edit" do
#     it "assigns the requested trip as @trip" do
#       pending("there is no routing match this routing")
#       user = login_user
#       my_trip = build_trip(user.id)
#       get :edit, {:id => my_trip.id}
#       expect(response).to have_http_status(200)
#       expect(response).to be_success
#       expect(assigns(:trip)).to eq(my_trip)
#     end
#   end

#   describe "POST #create" do
#     context "with valid params" do

#        it "sign in as user creates a new Trip" do
#       @request.headers["Accept"] = "application/json"
#       @request.env["CONTENT_TYPE"] = "application/json"
#       user=login_user
#       post :create , {  
#         format: :json,
#                :locations =>  [ 
                
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456867 },
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456868 },
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456869 },
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456860 },
#                                 ]
#               }, as: :json

#       json = JSON.parse response.body
#       expect(response).to have_http_status(200)
#       expect(response).to be_success
#       expect(json['success']).to eq(true)
#       trip=Trip.find_by(user: user.id)
#       expect(trip).not_to be_nil
#       segment=Segment.find_by(trip: trip.id)
#       expect(segment).not_to be_nil
#       test_locations=Location.where(segment: segment.id)
#       expect(test_locations.length).to eq(4)
#       end



#       it "sign in as admin creates a new Trip" do
#       @request.headers["Accept"] = "application/json"
#       @request.env["CONTENT_TYPE"] = "application/json"
#       user=login_admin
#       post :create , 
#               {  format: :json,
#                :locations =>  [ 
                
#               {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456867 },
#                 ]
#               }, as: :json

#       json = JSON.parse response.body
#       expect(response).to have_http_status(200)
#       expect(response).to be_success
#       expect(json['success']).to eq(true)
#       trip=Trip.find_by(user: user.id)
#       expect(trip).not_to be_nil
#       segment=Segment.find_by(trip: trip.id)
#       expect(segment).not_to be_nil
#       test_locations=Location.where(segment: segment.id)
#       expect(test_locations.length).to eq(1)
#       end


#       it "sign in as researcher creates a new Trip" do
#       @request.headers["Accept"] = "application/json"
#       @request.env["CONTENT_TYPE"] = "application/json"
#       user=login_researcher
#       post :create , 
#               {  format: :json,
#                :locations =>  [ 
                
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456867 },
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456868 },
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456869 },
#                   {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456860 },
#                                 ]
#               }, as: :json

#       json = JSON.parse response.body
#       expect(response).to have_http_status(200)
#       expect(response).to be_success
#       expect(json['success']).to eq(true)
#       trip=Trip.find_by(user: user.id)
#       expect(trip).not_to be_nil
#       segment=Segment.find_by(trip: trip.id)
#       expect(segment).not_to be_nil
#       test_locations=Location.where(segment: segment.id)
#       expect(test_locations.length).to eq(4)
#       end

#     end

#     context "with invalid params" do

#       it "did not sign in can not create" do
#       @request.headers["Accept"] = "application/json"
#       @request.env["CONTENT_TYPE"] = "application/json"
     
#         post :create , 
#               {  format: :json,
#                :locations =>  [ 
#               {:latitude => 75.3, :longitude => 120.3, :speed => 20.5, :accuracy => 15.3, :time => 123456867 },
#                 ]
#             }, as: :json

#       expect(response).to have_http_status(401)
#       expect(response).not_to be_success

#       end


#        it "sign in as user cannot create a trip without locations" do
#       @request.headers["Accept"] = "application/json"
#       @request.env["CONTENT_TYPE"] = "application/json"
#       user=login_user
#       expect {post :create , 
#               {  format: :json,
#                :locations =>  [ 
#                 ]
#               }, as: :json
#               }.to raise_error(ActionController::ParameterMissing)
#       end
#       # it "assigns a newly created but unsaved trip as @trip" do
#       #   post :create, {:trip => invalid_attributes}, valid_session
#       #   expect(assigns(:trip)).to be_a_new(Trip)
#       # end

#       # it "re-renders the 'new' template" do
#       #   post :create, {:trip => invalid_attributes}, valid_session
#       #   expect(response).to render_template("new")
#       # end
#     end
#   end



#       # expect(:get => "/trips/#{my_trip.id}").to route_to("trips#show", :id => "#{my_trip.id}")
#   describe "PUT #update" do

#       it "updates the requested trip split it into two parts" do
#       user = login_user
#       my_trip = build_trip(user.id)
#       # server_response = get "/trips/#{my_trip.id}"
#        # server_response = get "/trips/new"
#       # server_response = get :show, {:id => my_trip.id}
#       old_seg= my_trip.segments[0]
#       put :update => "/trips/#{my_trip.id}", :id => my_trip.id,
#               :trip =>{
#                 :segments_attributes => [{:id => old_seg.id, :transportation => "Walk", :order => old_seg.id, 
#                                           :locations_attributes => [{:id => old_seg.locations[0].id, :latitude => -75.3, :longitude => -125.3},
#                                                                     {:id => old_seg.locations[1].id, :latitude => -70.3, :longitude => -120.3},
#                                                                                                   ]},
#                                           {:transportation => "Car", 
#                                           :locations_attributes => [{:id => old_seg.locations[2].id, :latitude => -65.3, :longitude => -115.3},
#                                                                     {:id => old_seg.locations[3].id, :latitude => -60.3, :longitude => -110.3},
#                                                                                                   ]},
#                                         ]
#                       }
             

#       my_trip.reload
#       expect(my_trip.segments[0].locations.length).to eq(2)
#       expect(my_trip.segments[1].locations.length).to eq(2)
#       expect(response).to have_http_status(200)
#       expect(response).to be_success
#       expect(assigns(:trip)).to eq(my_trip)

#       end


#       it "updates the requested trip split it into four parts" do
#       user = login_user
#       my_trip = build_trip(user.id)

#       old_seg= my_trip.segments[0]
#       put :update , 
#               { format: :json,:id => my_trip.id,
#               :trip =>{
#                 :segments_attributes => [{:id => old_seg.id, :transportation => "Walk", :order => old_seg.id, 
#                                           :locations_attributes => [{:id => old_seg.locations[0].id, :latitude => -75.3, :longitude => -125.3},
#                                                                     ]},
#                                            {:transportation => "Walk", :order => old_seg.id, 
#                                           :locations_attributes => [{:id => old_seg.locations[1].id, :latitude => -70.3, :longitude => -120.3},
#                                                                     ]},
#                                           {:transportation => "Bus", 
#                                           :locations_attributes => [{:id => old_seg.locations[2].id, :latitude => -65.3, :longitude => -115.3},
#                                                                     ]},
#                                           {:transportation => "Tram", 
#                                           :locations_attributes => [{:id => old_seg.locations[3].id, :latitude => -60.3, :longitude => -110.3},
#                                                                     ]}                                                        
#                                         ]
#                       }
#               }, as: :json

#       my_trip.reload
#       expect(my_trip.segments[0].locations.length).to eq(1)
#       expect(my_trip.segments[1].locations.length).to eq(1)
#       expect(my_trip.segments[2].locations.length).to eq(1)
#       expect(my_trip.segments[3].locations.length).to eq(1)
#       expect(response).to have_http_status(200)
#       expect(response).to be_success


#       end

#     context "with invalid params" do

#       it "updates the requested trip substitute it with nothing" do
#       user = login_user
#       my_trip = build_trip(user.id)
#       # server_response = get "/trips/#{my_trip.id}"
#        # server_response = get "/trips/new"
#       # server_response = get :show, {:id => my_trip.id}
#       old_seg= my_trip.segments[0]
#       put :update , 
#               { format: :json,:id => my_trip.id,
#               :trip =>nil

#               }, as: :json

#       my_trip.reload
#       expect(my_trip.segments[0].startTime).to be_nil
#       expect(my_trip.segments[0].endTime).to be_nil
#       expect(my_trip.segments[0].transportation).to be_nil

#       expect(response).to have_http_status(400)
#       expect(response).not_to be_success


#       end

#     end
#   end

#   # describe "DELETE #destroy" do
#   #   it "destroys the requested trip" do
#   #     trip = Trip.create! valid_attributes
#   #     expect {
#   #       delete :destroy, {:id => trip.to_param}, valid_session
#   #     }.to change(Trip, :count).by(-1)
#   #   end

#   #   it "redirects to the trips list" do
#   #     trip = Trip.create! valid_attributes
#   #     delete :destroy, {:id => trip.to_param}, valid_session
#   #     expect(response).to redirect_to(trips_url)
#   #   end
#   # end





# end
