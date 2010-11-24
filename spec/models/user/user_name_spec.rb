require File.dirname(__FILE__) + '/../../spec_helper'

describe User::Name do
  describe 'parts' do
    it 'has a first'
    it 'has a last'
    it 'has a middle'
  end
  
  describe 'parse' do
    describe 'first last' do
      it 'should find the first name'
      it 'should find the last name'
      it 'should handle a hyphenate last name'
    end
    
    describe 'last, first' do
      it 'should find the first name'
      it 'should find the last name'
    end
    
    describe 'first middle last' do
      it 'should find the first name'
      it 'should find the last name'
      it 'should find the middle name'
      it 'should put extra names in the middle'
    end
  end
  
  describe 'mongoing' do
    describe '#to_mongo' do
      it 'should be an empty hash by default'
      it 'should save as a hash with keys corresponding to name parts'
    end
    
    describe '#from_mongo' do
      it 'should translate initalize with the hash'
    end
  end
end
