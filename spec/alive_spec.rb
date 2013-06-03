require 'spec_helper'

describe "specs working in Rubymine" do
  it "should pass" do
    expect{true}.to be_true 
  end
end

describe "First name is 'Jim'" do
  it "must refer to itself as 'Jim'" do
    'Jim'
  end
end

describe "can find one string in another" do
  specify "should find 'sd' in 'asdf'" do

    a = 'sd'
    b = 'asdf'
    expect(b).to match /.*sd.*/

  end
end
