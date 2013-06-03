require 'spec_helper'

describe "specs working in Rubymine" do
  it "should pass" do
    expect{true}.to be_true 
  end
end

describe "mb's test" do
  specify "that [1,2,3] has 3 elements" do
    expect([1,2,3].length == 3)
  end
end
