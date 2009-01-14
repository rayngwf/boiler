require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
include AuthenticatedTestHelper

describe ApplicationHelper do

  describe "title" do
    it "should set @content_for_title" do
      title('hello', nil).should be_nil
      @content_for_title.should eql('hello')
    end

    it "should output container if set" do
      title('hello', :h2).should have_tag('h2', 'hello')
    end
  end

end