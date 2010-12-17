require 'spec_helper'

describe SessionsController do
  def mock_user(stubs={})
    (@mock_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end
  
  describe "GET /session/new" do
    before do
      get :new
    end
    
    it 'should be successful' do
      response.should be_success
    end
  end
  
  describe "POST /session" do
    before do
      @user = User.new(
        :email => 'mock@foo.com',
        :password => 'password',
        :username => 'mock_foo'
      )
    end
    
    describe 'good credentials' do
      before do
        @session = {
          :login => @user.email,
          :password => 'password'
        }
        User.stub!(:authenticate).and_return(@user)
      end
      
      it 'should authenticate the user' do
        User.should_receive(:authenticate).with( @session.stringify_keys ).and_return(@user)
        post :create, :session => @session
      end
      
      it 'should create a new session with the user' do
        post :create, :session => @session
        @controller.session[:user_id].should == @user.id.to_s
      end
      
      it 'should set the current user' do
        post :create, :session => @session
        @controller.current_user.should == @user
      end
      
      it 'sets the flash' do
        post :create, :session => @session
        @controller.flash[:notice].should == 'You have been logged in.'
      end
      
      it 'redirects to home if no location is saved' do
        post :create, :session => @session
        response.should redirect_to('/')
      end
      
      it 'redirects to a location if one was saved in the cookie' do
        @request.cookies["location"] = "/foo/new"
        post :create, :session => @session
        response.should redirect_to('/foo/new')
      end
      
      it 'redirects to a passed location' do
        post :create, :session => @session, :location => '/foo/bar'
        response.should redirect_to('/foo/bar')
      end
      
      describe 'remembering' do
        describe 'option passed in' do
          before do
            @session.merge!(:remember => true)
          end
          
          it 'sets the remember token on the user' do
            @user.should_receive(:remember!)
            post :create, :session => @session
          end
          
          it 'sets a remember token in the cookie' do
            @user.should_receive(:remember!).and_return('remember_cookie')
            post :create, :session => @session
            cookies[:remember].should == 'remember_cookie'
          end
        end
        
        describe 'option not passed' do
          it 'does not set the remember token on the user' do
            @user.should_not_receive(:remember!)
            post :create, :session => @session
          end
          
          it 'does not set the remember token on the cookie' do
            post :create, :session => @session
            cookies[:remember].should be_nil
          end
        end 
      end
    end
    
    describe 'bad credentials' do
      before do
        @session = {
          :login => @user.email,
          :password => 'password'
        }
        User.stub!(:authenticate).and_return(nil)
      end
      
      it 'does not add the user to the session' do
        post :create, :session => @session
        @controller.session[:user_id].should be_nil
      end
      
      it 'does not set the current user' do
        post :create, :session => @session
        @controller.current_user.should be_nil
      end
    end
  end
  
  describe 'DELETE /session' do
    before do
      @user = User.new(
        :email => 'mock@foo.com',
        :password => 'password',
        :username => 'mock_foo'
      )
      
      @controller.params = {
        :session => {:remember => true}
      }
      @controller.login( @user )
    end
    
    it 'should set the flash' do
      delete :destroy 
      @controller.flash[:error].should == 'You have been logged out.'
    end
    
    it 'should redirect to home' do
      delete :destroy
      response.should redirect_to("/")
    end
    
    it 'should destroy the remember token on the user' do
      @user.should_receive(:forget!)
      delete :destroy
    end
    
    it 'should destroy the remember token on the cookie' do
      delete :destroy
      response.cookies[:remember].should be_nil
    end
    
    it 'should unset the current user' do
      delete :destroy
      @controller.current_user.should == nil
    end
    
    it 'should empty the session' do
      delete :destroy
      @controller.session[:user_id].should be_nil
    end
  end  
end
