# frozen_string_literal: true

describe Biodiversity do
  describe 'version' do
    it 'returns version of Biodiversity gem' do
      expect(subject.version).to match(/\d+\.\d+\.\d+/)
    end
  end
end
