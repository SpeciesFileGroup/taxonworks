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

describe "matt's test" do 
  # it/specify are aliases 
  specify "that foo is not found in some hash in either keys or values" do
    some_hash = {a: 1, b: 2, c: [], d: nil, blorf: "borf"}
    expect(some_hash.keys.select{|a| a == "foo"}.size).to eq(0)  
    expect(some_hash.values.select{|a| a == "foo"}).to match_array([]) 
    expect(some_hash.values.select{|a| a == "foo"}).to have(0).things
    expect(some_hash.values.select{|a| a == "foo"}).to eql([])
  end

end


describe "rich's test" do
  it "test number of keys" do
    expect({:a=>:b}.keys).to have(1).things
  end
end

