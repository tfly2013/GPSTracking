require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe UsersController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
  	# User.new(:email => "userkaiqi@test.com", :password => "abc123456",:role => 0)
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # login_user
  # login_researcher
  # login_admin
  # build_many_user
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "did not sign in then denied" do
      @request.headers["Accept"] = "application/json"
	    @request.env["CONTENT_TYPE"] = "application/json"
      user = User.all
      get :index
      expect(response).not_to have_http_status(200)
      expect(response).to have_http_status(401)
      expect(response).not_to be_success
    end
    
    it "sign in as user then denied" do
    	login_user
      user = User.all
      # get :index
      expect { get :index }.to raise_error(ActionController::RedirectBackError)
      # expect(response).to redirect_to :back
      # expect(response).not_to be_success
    end
    
    it "sign in as researcher then denied" do
      	login_researcher
      user = User.all
      expect { get :index }.to raise_error(ActionController::RedirectBackError)
    end

    it "sign in as admin then success" do
      	login_admin
      user = User.all
      get :index
      expect(response).to have_http_status(200)
      expect(response).to be_success
      expect(assigns(:users)).to eq(user)
    end

  end


  # path coveratge
  describe "GET #show" do
    it "did not sign in" do
      build_many_user
      user = User.all.first
      get :show, {:id => user.id} 
      expect(assigns(:user)).not_to eq(user)
      # expect(response).to be_nil
	  # @flashes ={"alert"=>"You need to sign in or sign up before continuing."
      expect(response).to have_http_status(302)
      expect(response).not_to be_success
    end

    it "sign in as user then show itself successfully" do
      user=login_user
      get :show, {:id => user.id}
      expect(assigns(:user)).to eq(user)
    end

    it "sign in as user then fail to show other" do
      build_many_user
      user=login_user
      ano_id=user.id-1
      expect {get :show, {:id => ano_id}}.to raise_error(ActionController::RedirectBackError)
    end


      it "sign in as researcher then show itself successfully" do
      user=login_researcher
      get :show, {:id => user.id}
      expect(assigns(:user)).to eq(user)
    end

    it "sign in as researcher then fail to show other" do
      build_many_user
      user=login_researcher
      ano_id=user.id-1
      expect {get :show, {:id => ano_id}}.to raise_error(ActionController::RedirectBackError)
    end

    it "sign in as admin then show other successfully" do
      build_many_user
      user=login_admin
      ano_id=user.id-1
      ano_user= User.find(ano_id)
      get :show, {:id => ano_id}
      expect(assigns(:user)).to eq(ano_user)

    end

  end



  describe "PUT #update" do
    context "with valid params" do

      it "updates the requested user successfully" do
      	build_many_user
        user = login_admin
        ano_user = User.all.first
        put :update, :id => ano_user.id, :user => {:role => User.roles.keys.to_a[1]}
        ano_user.reload
        expect(ano_user['role']).to eq(1)
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to eq("User updated.")
      end




      # it "assigns the requested user as @user" do
      #   user = User.create! valid_attributes
      #   put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
      #   expect(assigns(:user)).to eq(user)
      # end

      # it "redirects to the user" do
      #   user = User.create! valid_attributes
      #   put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
      #   expect(response).to redirect_to(user)
      # end
    end

    context "with invalid params" do
        it "user can not updates" do
        build_many_user
        user = login_user
        ano_user = User.all.first
        expect {put :update, :id => ano_user.id, :user => {:role => User.roles.keys.to_a[1]}}.to raise_error(ActionController::RedirectBackError)
        end

        it "researcher can not updates" do
        build_many_user
        user = login_researcher
        ano_user = User.all.first
        expect {put :update, :id => ano_user.id, :user => {:role => User.roles.keys.to_a[1]}}.to raise_error(ActionController::RedirectBackError)
        end

        it "failed to update with a out of range value of role" do
        pending("out of range value of role")
        build_many_user
        user = login_admin
        ano_user = User.all.first
        put :update, :id => ano_user.id, :user => {:role => User.roles.keys.to_a[6]}
        expect(response).not_to have_http_status(200)
        expect(response).to have_http_status(302)
        expect(response).not_to be_success
        # expect(ano_user['role']).to eq(1)
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).not_to eq("User updated.")
        expect(flash[:alert]).to eq( "Unable to update user.")
        end

        it "failed to update with invalid id" do
        build_many_user
        user = login_admin
        ano_user = User.all.first
        expect {  put :update, :id => ano_user.id-10, :user => {:role => User.roles.keys.to_a[1]}}.to raise_error(ActiveRecord::RecordNotFound)
        end

    #   it "assigns the user as @user" do
    #     user = User.create! valid_attributes
    #     put :update, {:id => user.to_param, :user => invalid_attributes}, valid_session
    #     expect(assigns(:user)).to eq(user)
    #   end

    #   it "re-renders the 'edit' template" do
    #     user = User.create! valid_attributes
    #     put :update, {:id => user.to_param, :user => invalid_attributes}, valid_session
    #     expect(response).to render_template("edit")
    #   end
    end
  end

  describe "DELETE #destroy" do
    it "sign in as admin destroys the user" do
      build_many_user
      user=login_admin
      ano_user = User.all.first
      ano_user_id=ano_user.id
      delete :destroy, :id => ano_user.id
      expect {ano_user.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect {User.find(ano_user_id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

      it "sign in as user can not destroys the user" do
      build_many_user
      user=login_user
      ano_user = User.all.first
      expect {delete :destroy, :id => ano_user.id}.to raise_error(ActionController::RedirectBackError)
    end

      it "sign in as researcher can not destroys the user" do
      build_many_user
      user=login_researcher
      ano_user = User.all.first
      expect {delete :destroy, :id => ano_user.id}.to raise_error(ActionController::RedirectBackError)
    end

    # it "redirects to the users list" do
    #   user = User.create! valid_attributes
    #   delete :destroy, {:id => user.to_param}, valid_session
    #   expect(response).to redirect_to(users_url)
    # end
  end

end




  # describe "GET #new" do
  #   it "assigns a new user as @user" do
  #     get :new, {}, valid_session
  #     expect(assigns(:user)).to be_a_new(User)
  #   end
  # end

  # describe "GET #edit" do
  #   it "assigns the requested user as @user" do
  #     user = User.create! valid_attributes
  #     get :edit, {:id => user.to_param}, valid_session
  #     expect(assigns(:user)).to eq(user)
  #   end
  # end

  # describe "POST #create" do
  #   context "with valid params" do
  #     it "creates a new User" do
  #       expect {
  #         post :create, {:user => valid_attributes}, valid_session
  #       }.to change(User, :count).by(1)
  #     end

  #     it "assigns a newly created user as @user" do
  #       post :create, {:user => valid_attributes}, valid_session
  #       expect(assigns(:user)).to be_a(User)
  #       expect(assigns(:user)).to be_persisted
  #     end

  #     it "redirects to the created user" do
  #       post :create, {:user => valid_attributes}, valid_session
  #       expect(response).to redirect_to(User.last)
  #     end
  #   end

  #   context "with invalid params" do
  #     it "assigns a newly created but unsaved user as @user" do
  #       post :create, {:user => invalid_attributes}, valid_session
  #       expect(assigns(:user)).to be_a_new(User)
  #     end

  #     it "re-renders the 'new' template" do
  #       post :create, {:user => invalid_attributes}, valid_session
  #       expect(response).to render_template("new")
  #     end
  #   end
  # end