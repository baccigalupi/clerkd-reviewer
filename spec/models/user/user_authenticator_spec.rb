require File.dirname(__FILE__) + '/../../spec_helper'

describe 'User Authetication' do
  describe Authentication, 'Module' do
    describe 'authentication' do
      describe 'authenticate( password )' do
        it 'returns the user if the password encypts correctly'
        it 'returns false if the password does not encrypt correctly'
      end

      describe 'self.authenticate(login, password)' do
        it 'finds a user by login (username or email)'
        it 'returns nil if a user is not found'
        it 'returns false if the user is not authenticated'
        it 'returns the user if the password authenticates'
      end
    end
    
    describe 'authenticators' do
      before do
        @user = User.new
      end
      
      it 'has a place to store some' do
        @user.authenticators.should == []
      end
      
      describe '#remember!' do
        it 'adds a RememberToken to the authenticators' do
          @user.authenticators.should be_empty
          @user.remember!
          @user.authenticators[:remember].should_not be_nil
          @user.authenticators[:remember].class.should == RememberToken
        end
        
        it 'sets the token' do
          @user.remember!
          @user.authenticators[:remember].code.should_not be_nil
          @user.authenticators[:remember].expires_at.should be_close(
            Time.now + RememberToken::PERIOD, 
            10.seconds
          )
        end
        
        it 'saves the token' do
          @user.stub!(:valid?).and_return(true)
          @user.remember!
          @user.reload
          @user.authenticators[:remember].should_not be_nil
        end
        
        it 'returns the code' do
          @user.remember!.is_a?(String).should be_true
        end
        
        describe 'avoiding duplication' do
          it 'will not add duplicate RemeberToken to authenticators' do
            @user.remember!
            @user.remember!
            @user.authenticators.select{|a| a.class == RememberToken}.size.should == 1
          end
          
          it 'should change the code in the remember token' do
            @user.remember!
            remember = @user.authenticators[:remember].dup
            
            time = Time.now
            Time.stub!(:now).and_return(time + 3.minutes)
            
            @user.remember!
            @user.authenticators[:remember].code.should_not == remember.code
          end
        end
      end
      
      describe '#forget!' do
        it 'removes the token' do
          @user.remember!
          @user.authenticators[:remember].should_not be_nil
          @user.forget!
          @user.authenticators[:remember].should be_nil
        end
      end
      
      describe 'password=' do
        it 'it puts a Password authenticator into authenticators' do
          @user.authenticators.should be_empty
          @user.password = 'password'
          @user.authenticators[:password].should_not be_nil
          @user.authenticators[:password].class.should == Password
        end
        
        it 'sets the Password object' do
          @user.password = 'password'
          @user.authenticators[:password].salt.should_not be_nil
          @user.authenticators[:password].encryption.should == 
            @user.authenticators[:password].encrypt_password('password')
        end
        
        describe 'setting multiple times' do
          it 'should not duplicate the password object in authenticators' do
            @user.password = 'password'
            @user.password = 'new password'
            @user.authenticators.select{|a| a.class == Password }.size.should == 1
          end
        
          it 'should set the existing password object with the new password' do
            @user.password = 'password'
            @user.password = 'new password'
            @user.authenticators[:password].encryption.should == 
              @user.authenticators[:password].encrypt_password('new password')
          end
        end
      end
    end
  end
  
  describe Password do
    before do
      @password = Password.new
    end
    
    describe 'initialize' do
      it 'will create an empty object when it does not receive arguments' do
        @password.salt.should == nil
        @password.encryption.should == nil
      end
      
      it 'will set the accessor when options are passed in' do
        password = Password.new(:salt => 'my_salt', :encryption => 'encrypted')
        password.salt.should == 'my_salt'
        password.encryption.should == 'encrypted'
      end
    end
    
    describe 'set' do
      before do
        @password.salt.should == nil
        @password.encryption.should == nil
        @password.set('password')
      end
      
      it 'creates salt' do
        @password.salt.should_not == nil
      end
      
      it 'encrypts the password' do
        @password.encryption.should == @password.encrypt_password('password')
      end
      
      it 'returns the Pasword object' do
        @password.set('password').should == @password
      end
    end
    
    describe 'authentication' do
      it 'should work with the correct password' do
        @password.set('password')
        @password.authenticate('password').should == true
      end
      
      it 'should return false if the password is not correct' do
        @password.set('password')
        @password.authenticate('not the password').should == false
      end
    end
  end
  
  describe Token do
    before do
      @token = Token.new
    end
    
    describe 'initialize' do
      it 'will create an empty object when it does not receive arguments' do
        @token.code.should == nil
        @token.expires_at.should == nil
      end
      
      it 'will set the accessor when options are passed in' do
        token = Token.new(:code => 'my_code', :expires_at => Time.parse('1/1/1970'))
        token.code.should == 'my_code'
        token.expires_at.should == Time.parse('1/1/1970')
      end
    end
    
    describe 'set' do
      before do
        @token.set
      end
      
      it 'sets the code' do
        @token.code.should_not be_nil
      end
      
      it 'sets the expries at time' do
        @token.expires_at.should be_close( Time.now + 2.weeks, 10.seconds ) 
      end
      
      it 'returns a token object' do
        @token.set.class.should == Token
      end
    end
    
    describe 'authenticate' do
      it 'is true if the expiration has not expired' do
        @token.expires_at = Time.now + 2.weeks
        @token.authenticate.should == true
      end
      
      it 'is false if expiration has expired' do
        @token.expires_at = Time.now - 2.weeks
        @token.authenticate.should == false
      end
    end
  end
end