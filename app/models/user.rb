class User < Model
  key :username
  
  validates_presence_of :username,              
    :message => 'is required'
  validates_format_of   :username, :with => /^[a-z0-9]*$/, 
    :message => 'should be only letters and numbers with so spaces or special characters'
end