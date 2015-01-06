require 'rails_helper'

describe RandomToken do
  describe "::generate" do
    it "returns SecureRandom.urlsafe_base64 return value" do
      value = SecureRandom.urlsafe_base64
      allow(SecureRandom).to receive(:urlsafe_base64).and_return(value)
      expect(RandomToken.generate).to eq(value)
    end
    
    it "returns a token with at least 16 chars" do
      expect(RandomToken.generate).to satisfy { |v| v.length >= 16 }
    end
    
  end
  
  describe "::digest" do
    let(:digest) { RandomToken.digest(RandomToken.generate) }
    
    it "returns a hex digest of the supplied string" do
      expect(digest).to match(/^[0-9a-fA-F]*$/)
    end
    
    it "returns a hex digest of at least 160 bits" do
      expect(digest).to satisfy { |v| v.length >= 160/4 }
    end
    
  end
    
end
