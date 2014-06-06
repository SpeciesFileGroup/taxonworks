require 'spec_helper'

describe "DataAttributes" do
  describe "GET /data_attributes" do
    before { visit data_attributes_path }
    specify 'an index name is present' do
      expect(page).to have_content('Data Attributes')
    end
  end
end
