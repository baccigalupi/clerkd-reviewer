require File.dirname(__FILE__) + '/../../spec_helper'

describe 'User Authetication' do
  describe Authentication, 'Module' do
    describe 'authentication' do
      describe 'self.authenticate(opts)' do
        it 'calls authenticate_by_password' do
          User.should_receive(:authenticate_by_password)
          User.authenticate({})
        end
        
        it 'calls authenticate_by_remember' do
          User.should_receive(:authenticate_by_remember)
          User.authenticate({})
        end
        
        it 'should not call authenticate_by_remember if authenticate_by_password works' do
          User.should_not_receive(:authenticate_by_remember)
          User.should_receive(:authenticate_by_password).and_return( User.new )
          User.authenticate({})
        end
          
        describe 'self.authenticate_by_password' do
          before do
            @user = User.new(:password => 'password')
          end
          
          it 'returns nil if there is not a :login option' do
            User.authenticate_by_password({:password => 'where is the login'}).should == nil
          end
          
          it 'should search for a user when provided a :login option' do
            User.should_receive(:first).and_return(@user)
            User.authenticate_by_password(:login => 'my_login')
          end
          
          describe 'will find a user by' do
            it 'username' do
              User.should_receive(:first).with(:username => 'kane').and_return(@user)
              User.authenticate(:login => 'kane')
            end
            
            it 'email' do
              User.should_receive(:first).with(:username => 'baccigalupi@gmail.com').ordered.and_return(nil)
              User.should_receive(:first).with(:email => 'baccigalupi@gmail.com').ordered.and_return(@user)
              User.authenticate(:login => 'baccigalupi@gmail.com')
            end
          end
          
          describe 'when a user is found' do
            before do
              User.should_receive(:first).and_return(@user)
              @params = {:login => 'kane', :password => 'password'}
            end
            
            it 'calls #authenticate on the user\'s password object' do
              @user.authenticators[:password].should_receive(:authenticate).and_return(@user)
              User.authenticate_by_password(@params)
            end
            
            it 'passes #authenticate the :password option it receives' do
              @user.authenticators[:password].should_receive(:authenticate).with(@params[:password]).and_return(@user)
              User.authenticate_by_password(@params)
            end
          end
        end
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