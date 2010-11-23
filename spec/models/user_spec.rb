require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it 'should be a Model' do
    User.ancestors.include?(Model).should be_true
  end
  
  describe 'attributes' do
    describe 'username' do
      before do
        @user = User.new
      end
      
      it 'has one' do
        @user.username = 'Bob'
        @user.username.should == 'Bob'
      end
      
      it 'is required' do
        @user.valid?.should be_false
        @user.errors[:username].should_not be_empty
        @user.errors[:username].first.should == "is required"
      end
      
      it 'should not allow spaces' do
        @user.username = "Bob Johnson"
        @user.valid?.should be_false
        @user.errors[:username].should_not be_nil
        @user.errors[:username].first.should == 'should be only letters and numbers with so spaces or special characters'
      end
      
      it 'should not allow CGI escapable characters' do
        @user.username = "Bob/"
        @user.valid?.should be_false
        @user.errors[:username].should_not be_nil
        @user.errors[:username].first.should == 'should be only letters and numbers with so spaces or special characters'
      end
      
      # what about unicode? probably not for this app
    end
    
    describe 'email' do
      it 'has one'
      it 'is required'
      it 'should be a valid email'
    end
    
    it 'has timestamps'
    
    describe 'name' do
      # this is really a name object
      it 'is a hash'
      it 'has a #first_name'
      it 'has a #last_name'
      it 'has a #display_name'
    end
  end
  
  describe 'roles' do
    it 'is an array'
    it 'is an empty array by default'
    
    describe 'role=' do
      it 'adds a role to role'
      it 'will not add a role that is not real'
      it 'cannot be set with the create attributes'
      it 'cannot be set with update attributes'
    end
    
    describe 'admin?' do
      it 'is true for ??'
    end
    
    describe 'is?' do
      pending 'waiting to see how we need to use roles'
    end
  end
  
  describe 'tokens' do
    it 'is a Hash'
    
    describe 'remember token' do
      it 'is a Token'
      it 'corresponds to the :remember key in tokens'
      
      describe '#remember!' do
        it 'sets the token code'
        it 'sets the expiration to the default period for the token type'
        it 'alternately sets the expiration to the value passed in'
      end
    end
    
    describe 'lost password token' do
    end
    
    describe '#find_by_token(code, type=RememberToken)' do
      it 'returns the found user if the token has not expired'
      it 'returns nil if no user corresponds to that token'
      it 'returns nil if the token has expired'
    end
  end
  
  describe 'authentication' do
    # not sure if this is necessary since we are auditing the user actions
    # it 'has #logged_in_at'
    # describe 'login_times' do
    #   it 'is an array'
    #   it 'is an empty array by default'
    #   it '#login adds a time to the head of the array'
    #   it '#login removes excess login times after adding new times'
    # end
    
    describe 'password=' do
      it 'sets the salt if there is none'
      it 'encrypts the password'
    end
    
    describe 'authenticate( password )' do
      it 'returns the user if the password encypts correctly'
      it 'returns false if the password does not encrypt correctly'
    end
    
    describe 'self.authenticate(login, password)' do
      it 'returns nil if a user is not found'
      it 'returns false if the user is not authenticated'
      it 'returns the user if the password authenticates'
    end
  end
end
