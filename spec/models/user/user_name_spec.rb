require File.dirname(__FILE__) + '/../../spec_helper'

describe User::Name do
  describe 'Name.parse' do
    describe 'first last' do
      before do
        @string = "Kane Baccigalupi"
      end
      
      it 'should return a Name object' do
        User::Name.parse('').is_a?(User::Name).should be_true
      end
      
      it 'should find the first name' do
        name_instance = User::Name.parse(@string)
        name_instance.first.should == "Kane"
      end
      
      it 'should find the last name' do
        User::Name.parse(@string).last.should == "Baccigalupi"
      end
      
      it 'should handle a hyphenated last name' do
        User::Name.parse("Rossana Segovia-Bain").last.should == 'Segovia-Bain'
      end
    end
    
    describe 'last, first' do
      before do
        @string = "Baccigalupi, Kane"
      end
      
      it 'should find the first name' do
        User::Name.parse(@string).first.should == 'Kane'
      end
      
      it 'should find the last name' do
        User::Name.parse(@string).last.should == 'Baccigalupi'
      end
      
      it 'should find everything even if there is no space' do
        name = User::Name.parse('Baccigalupi,Kane')
        name.first.should == 'Kane'
        name.last.should == 'Baccigalupi'
      end
    end
    
    describe 'first middle last' do
      before do
        # I couldn't use my name because my last name has a space in it
        @string = "Gabriela Mercedes Anahi Alexandra Bain"
      end
      
      it 'should find the first name' do
        User::Name.parse(@string).first.should == 'Gabriela'
      end
      
      it 'should find the last name' do
        User::Name.parse(@string).last.should == 'Bain'
      end
      
      it 'should find the middle name' do
        User::Name.parse("Gabriela Mercedes Bain").middle.should == 'Mercedes'
      end
      
      it 'should put extra names in the middle' do
        User::Name.parse(@string).middle.should == 'Mercedes Anahi Alexandra'
      end
    end
  end
  
  describe 'mongoing' do
    it 'should be a MongoMapper embedded document' do
      User::Name.new.is_a?(MongoMapper::EmbeddedDocument).should be_true
    end
    
    it 'should be a field in the user object' do
      user = User.new
      user.name = 'Fito von Zastrow'
      user.name_object.class.should == User::Name
    end
    
    it 'should persist name attributes' do
      user = User.new(:username => 'fito', :email => 'adolfovon@gmail.com', :name => 'Fito von Zastrow')
      user.save # MongoMapper persistance
      user.reload.name_object.first.should == 'Fito'
    end
  end
end
