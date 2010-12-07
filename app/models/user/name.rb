class User
  class Name
    include MongoMapper::EmbeddedDocument
    
    key :first, String
    key :last, String
    key :middle, String
    
    def self.parse(string)
      opts = if string.include?(',')
        name_array = string.split(',')
        name_array = name_array.map{|str| str.split(' ')}.flatten
        last = name_array.shift
        {:first => name_array.pop, :last => last}
      else
        name_array = string.split(' ')
        {:first => name_array.shift, :last => name_array.pop}
      end
      
      opts[:middle] = name_array.join(' ') if name_array.size > 0
      
      new(opts)
    end
  
    def full_name
      "#{first}#{middle ? ' ' + middle : ''}#{last ? ' ' + last : ''}"
    end
  end
end

