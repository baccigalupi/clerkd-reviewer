require 'digest/sha1'

class Authenticator
  include MongoMapper::EmbeddedDocument
end
  
class Password < Authenticator
  key :salt, String 
  key :encryption, String
  
  def set( password )
    self.salt = encrypt( "--#{object_id}--#{Time.now}--" )
    self.encryption = encrypt_password( password )
    self
  end
  
  def authenticate( password )
    encrypt_password( password ) == encryption
  end
  
  def encrypt_password( password )
    encrypt("--#{salt}--#{password}--")
  end
  
  def encrypt( string )
    Digest::SHA1.hexdigest( string )
  end
end

class Token < Authenticator
  PERIOD = 2.weeks
  
  key :code, String
  key :expires_at, Time
  
  def set
    self.expires_at = Time.now + self.class::PERIOD
    self.code =      Digest::SHA1.hexdigest("--#{object_id}--#{expires_at}--")
    self
  end
  
  def authenticate( *args )
    self.expires_at > Time.now
  end
end

class RememberToken < Token; end

class VerificationToken < Token
  PERIOD = 24.hours
end





module Authentication
  AUTHENTICATOR_KEY_MAP = {
    :password => 'Password',
    :remember => 'RememberToken',
    :verify =>   'VerificationToken'  
  }
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend  ClassMethods
      
      many :authenticators do
        def [](key)
          detect { |d| d.class.to_s == AUTHENTICATOR_KEY_MAP[key] }
        end
      end
    end
  end
  
  module InstanceMethods
    def authenticate()
    end
    
    def remember!
      self.authenticators << RememberToken.new unless authenticators[:remember]
      authenticators[:remember].set
      self.save
      authenticators[:remember].code
    end
    
    def forget!
      self.authenticators.delete(authenticators[:remember])
      self.save
    end
    
    def password=( p )
      self.authenticators << Password.new unless authenticators[:password]
      authenticators[:password].set(p)
      self.save
    end
  end
  
  module ClassMethods
    def authenticate(opts)
      authenticate_by_password(opts) ||
      authenticate_by_remember(opts) 
    end
    
    def authenticate_by_password(opts)
      if opts[:login] && user = User.first(:username => opts[:login]) || User.first(:email => opts[:login])
        user.authenticators[:password].authenticate(opts[:password])
      end
    end
    
    def authenticate_by_remember(opts)
    end
  end
end

class User
  include Authentication
end
