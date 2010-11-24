require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it 'should be a Model' do
    User.ancestors.include?(Model).should be_true
  end
  
  describe 'attributes' do
    before do
      @user = User.new
    end
    
    describe 'username' do
      it 'has one' do
        @user.username = 'Bob'
        @user.username.should == 'Bob'
      end
      
      it 'is required' do
        @user.valid?
        @user.errors[:username].should_not be_empty
        @user.errors[:username].first.should == "is required"
      end
      
      it 'should not allow spaces' do
        @user.username = "Bob Johnson"
        @user.valid?
        @user.errors[:username].should_not be_nil
        @user.errors[:username].first.should == 'should be only letters and numbers with so spaces or special characters'
      end
      
      it 'should not allow CGI escapable characters' do
        @user.username = "Bob/"
        @user.valid?
        @user.errors[:username].should_not be_nil
        @user.errors[:username].first.should == 'should be only letters and numbers with so spaces or special characters'
      end
      
      # what about unicode? probably not for this app
    end
    
    describe 'email' do
      it 'has one' do
        @user.email = 'bob@johnson.com'
        @user.email.should == 'bob@johnson.com'
      end
      
      it 'is required' do
        @user.valid?
        @user.errors[:email].first.should == 'is required'
      end
      
      it 'should be a valid email' do
        @user.email = 'boo hoo'
        @user.valid?
        @user.errors[:email].first.should == 'must be a valid email format'
        
        @user.email = 'baccigalupi@gmail.com'
        @user.valid?
        @user.errors[:email].should be_empty
      end
    end
    
    describe 'timestamps' do
      it 'has created_at' do
        @user.save(:validate => false)
        @user.created_at.is_a?(Time).should be_true
        @user.created_at.should be_close(Time.now, 10.seconds)
      end
      
      it 'has updated_at' do
        @user.save(:validate => false)
        @user.updated_at.is_a?(Time).should be_true
        original_date = @user.updated_at
        
        Time.stub!(:now).and_return(original_date + 1.day)
        @user.username = 'username'
        @user.save(:validate => false)
        @user.updated_at.should_not == original_date
        @user.updated_at.should be_close(original_date + 1.day, 10.seconds)
      end
    end
    
    describe 'name' do
      it 'is a User::Name'
      it 'sets with #name='
      it 'has a first_name'
      it 'has a display_name'
      it 'name allows access to the name object'
    end
  end
  
  describe 'roles' do
    before do
      @user = User.new
    end
    
    it 'is an array' do
      @user.roles.is_a?(Array)
    end
    
    it 'is an empty array by default' do
      @user.roles.should be_empty
    end
    
    describe 'role=' do
      it 'adds a role to role' do
        @user.role = :super_user
        @user.roles.should include(:super_user)
      end

      it 'will not add a role that is not established' do
        @user.role = :chief_poobah
        @user.roles.should_not include(:chief_poobah)
        @user.roles.should be_empty
      end
      
      it 'will convert a string role to a symbol' do
        @user.role = 'Super User'
        @user.roles.should include(:super_user)
      end
      
      it 'should not add duplicate roles' do
        @user.role = 'Super User'
        @user.role = 'Super User'
        @user.roles.should include(:super_user)
        @user.roles.size.should == 1
      end
      
      it 'cannot be set with the create attributes' do
        user = User.create(:role => 'Super User')
        user.roles.should be_empty
      end
      
      it 'cannot be set with update attributes' do
        @user.update_attributes(:role => 'Super User')
        @user.roles.should be_empty
      end
    end
    
    describe 'admin?' do
      [:super_user, :editor_manager, :editor].each do |role|
        it "is true for #{role}" do
          @user.roles = [role]
          @user.admin?.should be_true
        end
      end
      
      it 'should not be true for other users' do
        @user.roles = [:guest]
        @user.admin?.should be_false
      end
    end
    
    describe 'is?' do
      it "should be true when the role is in roles" do
        @user.roles = [:editor]
        @user.is?(:editor).should == true
      end
      
      it "should be false if the role is not in roles" do
        @user.roles = [:editor]
        @user.is?(:guest).should == false
      end
      
      it 'should take an array and match any of the values' do
        @user.roles = [:editor]
        @user.is?(:guest, :editor).should == true
      end
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
