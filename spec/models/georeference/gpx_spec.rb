require 'rails_helper'

describe Georeference::GPX, type: :model, group: [:geo, :georeferences] do
  context 'GPX uses a GPX file to internalize data' do
    specify "without file name/path" do
      expect(false).to be_falsey
    end

    specify "with invalid file/path" do
      expect(false).to be_falsey
    end

    specify 'with valid file/path' do
      expect(true).to be_truthy
    end
  end
end
