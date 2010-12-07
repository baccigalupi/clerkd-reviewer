class User < Model
  # SCHEMA -----------------------------
  key :username
  key :email
  key :roles, Array
  key :name_object, User::Name
  
  timestamps!
  
  # Validations -----------------------
  REQUIRED_MESSAGE = 'is required'
  
  validates_presence_of :username,              
    :message => REQUIRED_MESSAGE
  validates_format_of   :username, :with => /^[a-z0-9]*$/, 
    :message => 'should be only letters and numbers with so spaces or special characters'

  validates_presence_of :email, 
    :message => REQUIRED_MESSAGE
  validates_format_of :email, :with => /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/, 
    :message => 'must be a valid email format'

  
  # Attribute Helpers -----------------
  ROLES = {
    :editor => "Editor", 
    :editor_manager => "Editor Manager", 
    :guest => "Guest", 
    :reviewer => "Reviewer", 
    :super_user => "Super User"
  }
  
  INVERSE_ROLES = ROLES.invert
  
  ADMINS = [:super_user, :editor_manager, :editor]
  
  attr_protected :role
  def role=(r)
    if ROLES[r] || r = INVERSE_ROLES[r]
      self.roles << r unless roles.include?(r)
    end
    roles
  end
  
  def admin?
    (roles & ADMINS).size > 0
  end
  
  def is?(*array)
    (roles & array).size > 0
  end
  
  def name=(n)
    self[:name_object] = Name.parse(n)
  end
  
  def name
    name_object ? name_object.full_name : ''
  end
end