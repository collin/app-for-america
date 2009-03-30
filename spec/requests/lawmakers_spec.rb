require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/lawmakers" do
  before(:each) do
    @response = request("/lawmakers")
  end
end