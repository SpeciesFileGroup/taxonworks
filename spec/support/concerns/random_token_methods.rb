shared_examples 'random_token_methods' do
  
  def generate_test_token
    subject.send("generate_#{token_name}_token")
  end
  
  def test_token
    subject.send("#{token_name}_token")
  end
  
  def set_test_token(token)
    subject.send("#{token_name}_token=", token)
  end
  
  def test_token_date
    subject.send("#{token_name}_token_date")
  end
  
  def test_token_matches?(token)
    subject.send("#{token_name}_token_matches?", token)
  end
  
  describe '#generate_{token_name}_token' do
    it 'records the time it was generated' do
      Timecop.freeze(DateTime.now) do
        generate_test_token
        expect(test_token_date).to eq(DateTime.now)
      end
    end

    it 'generates a token from RandomToken.generate' do
      value = RandomToken.generate
      allow(RandomToken).to receive(:generate).and_return(value)      
      expect(generate_test_token).to eq(value)
    end

    it 'records the token digest computed like RandomToken.digest' do
      value = RandomToken.generate
      allow(RandomToken).to receive(:generate).and_return(value)
      generate_test_token
      expect(test_token).to eq(RandomToken.digest(value))     
    end

  end

  describe '#{token_name}_token_matches?' do

    context 'valid' do
      it "returns truthy when the supplied token matches the object's" do
        token = generate_test_token
        expect(test_token_matches?(token)).to be_truthy
      end
    end

    context 'invalid' do
      let(:examples) { [nil, '', 'token'] }

      it 'returns falsey when the subject has no token' do
        set_test_token(nil)
        examples.each { |e| expect(test_token_matches?(e)).to be_falsey }
      end

      it "returns falsey when the supplied token does not match the object's" do
        generate_test_token
        examples.each { |e| expect(test_token_matches?(e)).to be_falsey }
      end
    end
  end  
end