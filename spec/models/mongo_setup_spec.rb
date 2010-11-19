require File.dirname(__FILE__) + '/../spec_helper'

describe 'MongoMapper setup' do
  it 'mongo should be running' do
    `ps uwax | grep mongo`.should match(/mongod run/)
  end
  
  describe 'connection' do
    class ConnectionTest
      include MongoMapper::Document

      key :title, String
      key :description, String
    end
    
    it 'should create documents' do
      lambda{ 
        ConnectionTest.create({:title => 'Go Mongo', :description => 'I hope this works'})
      }.should_not raise_error
    end
    
    it 'should retrieve documents' do
      test_object = ConnectionTest.create({:title => 'Go Mongo', :description => 'I hope this works'})
      ConnectionTest.find(test_object.id).should == test_object
    end
  end
end