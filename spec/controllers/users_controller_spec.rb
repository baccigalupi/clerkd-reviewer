require 'spec_helper'

describe UsersController do
  def mock_user(stubs={})
    (@mock_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end
  
  describe 'GET /users (index)' do
    it "assigns all users as @users to the view" do
      User.stub(:all) { [mock_user] }
      get :index
      assigns(:users).should eq([mock_user])
    end
  end

  
  describe "GET /user/:id (show)" do
    it "assigns the requested user as @user" do
      User.stub(:find).with("37") { mock_user }
      get :show, :id => "37"
      assigns(:user).should be(mock_user)
    end
  end

  describe "GET /user/new" do
    it "assigns a new user as @user" do
      User.stub(:new) { mock_user }
      get :new
      assigns(:user).should be(mock_user)
    end
  end

  describe "GET /user/:id/edit" do
    it "assigns the requested user as @user" do
      User.stub(:find).with("37") { mock_user }
      get :edit, :id => "37"
      assigns(:user).should be(mock_user)
    end
  end

  describe "POST /users (create)" do
    describe "with valid params" do
      it "assigns a newly created user as @user" do
        @params = {'these' => 'params'}
        User.stub(:new).with(@params) { mock_user(:save => true) }
        post :create, :user => @params
        assigns(:user).should be(mock_user)
      end

      it "redirects to the index (/users)" do
        User.stub(:new) { mock_user(:save => true) }
        post :create, :user => {}
        response.should redirect_to(users_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        @params = {'these' => 'params'}
        
        User.stub(:new).with(@params) { mock_user(:save => false) }
        post :create, :user => @params
        assigns(:user).should be(mock_user)
      end

      it "re-renders the 'new' template" do
        User.stub(:new) { mock_user(:save => false) }
        post :create, :user => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT /user/:id (update)" do
    describe "with valid params" do
      it "updates the requested user" do
        User.should_receive(:find).with("37") { mock_user }
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user => {'these' => 'params'}
      end

      it "assigns the requested user as @user" do
        User.stub(:find) { mock_user(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:user).should be(mock_user)
      end

      it "redirects to the index (/users)" do
        User.stub(:find) { mock_user(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(users_url)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        User.stub(:find) { mock_user(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:user).should be(mock_user)
      end

      it "re-renders the 'edit' template" do
        User.stub(:find) { mock_user(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      User.should_receive(:find).with("37") { mock_user }
      mock_user.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the users list" do
      User.stub(:find) { mock_user }
      delete :destroy, :id => "1"
      response.should redirect_to(users_url)
    end
  end

end
