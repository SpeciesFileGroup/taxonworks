require 'rails_helper'

RSpec.describe Download, type: :model do
  let(:valid_attributes) { 
    strip_housekeeping_attributes(FactoryBot.build(:valid_download).attributes)
  }
  let(:download) { Download.create! valid_attributes }

  describe "#create" do
    it "stores a file in download directory" do
      expect(Rails.root.join('downloads', download.filename).exist?).to be_truthy
    end

  end

  describe "#file_path" do
    context "on create" do
      it "sets file_path relative to storage location" do
        expect(download.file_path).to eq("#{download.id}/#{download.filename}")
      end
    end

    context "on load" do
      it "points to the storage-relative path" do
        loaded = Download.find(download.id)
        expect(loaded.file_path).to eq("#{loaded.id}/#{loaded.filename}")
      end
    end
  end
end
