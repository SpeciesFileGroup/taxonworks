require 'spec_helper'

describe "specs working in Rubymine" do
  it "should pass" do
    expect{true}.to be_true 
  end
end

describe "mike's test" do
    
    specify "foo not equal to bar" do
       a = "foo"
        b="bar"
        expect(a).not_to eq(b)
    end
        
 end



