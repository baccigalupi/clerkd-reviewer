require File.dirname(__FILE__) + '/../spec_helper'

describe Model do
  it 'should mixin MongoMapper::Document' do
    Model.ancestors.should include MongoMapper::Document
  end
end
