class User
  class Name
    include MongoMapper::EmbeddedDocument
    
    key :first, String
    key :last, String
    key :middle, String
    
    def self.parse(string)
      name = new
      if string.include?(' ')
        array = string.split(' ')
        if string.include?(',')
          name.first = array.last
          name.last = array.first.chop
        else
          if array.size > 2 
            name.first = array.first
            name.middle = array.slice(1, ((array.size) - 2)).join(' ')
            name.last = array.last
          else  
            name.first = array.first
            name.last = array.last
          end
        end
      else
        if string.include?(',')
          array = string.split(',')
          name.first = array.last
          name.last = array.first
        else
          name.first = string
        end
      end
      name
    end
  
    def full_name
        if middle ==  nil && last == nil
          full = "#{first}"
        else
          full = "#{first} #{middle} #{last}"
        end
        full
    end
  end
end

