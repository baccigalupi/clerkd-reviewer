require 'digest/sha1'

class User
  class Authenticator
    def self.to_mongo( obj )
      !empty? ? obj.to_hash : nil
    end
    
    def self.from_mongo( hash )
      new( hash )
    end
    
    def initialize( opts=nil )
      if opts
        from_hash(opts)
      end
    end
    
    def to_hash
      hash = {}
      self.class::KEYS.each do |key|
        hash[key] = self.send(key)
      end
      hash
    end
    
    def from_hash(opts)
      self.class::KEYS.each do |key|
        self.send("#{key}=", opts[key])
      end
    end
  end
  
  class Password < Authenticator
    KEYS = [:salt, :encryption]
    attr_accessor *KEYS
    
    def empty?
      salt && encryption
    end
    
    def set( password )
      self.salt = encrypt("--#{object_id}--#{Time.now}--")
      self.encryption = encrypt_password( password )
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
    
    KEYS = [:code, :expires_at]
    attr_accessor *KEYS
    
    def set
      self.expires_at = Time.now + self.class::PERIOD
      self.code =      Digest::SHA1.hexdigest("--#{object_id}--#{expires_at}--")
    end
    
    def authenticate( *args )
      self.expires_at > Time.now
    end
  end
  
  class RememberToken < Token; end
  
  class VerificationToken < Token
    DELAY = 24.hours
  end
end

module Authentication
  AUTHENTICATORS = [
    User::RememberToken,
    User::Password,
    User::VerificationToken
  ]
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend  ClassMethods
    end
  end
  
  module InstanceMethods
    def authenticate()
    end
  end
  
  module ClassMethods
    def authenticate()
    end
  end
end

class User
  include Authentication
end
