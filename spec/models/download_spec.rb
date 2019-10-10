require 'rails_helper'

RSpec.describe Download, type: :model do
  # TODO: Avoid having to merge file_path when factory already provides this
  let(:valid_attributes) { 
    strip_housekeeping_attributes(FactoryBot.build(:valid_download).attributes.merge({ src_file_path: Rails.root.join('spec/files/downloads/Sample.zip') }))
  }

  let(:download) { Download.create! valid_attributes }
  let(:file_path) { Rails.root.join('downloads', download.id.to_s, download.filename) }

  describe "#create" do
    it "stores a file in download directory" do
      expect(file_path.exist?).to be_truthy
    end
  end

  describe "#file_path" do
    context "on create" do
      it "points to storage location" do
        expect(download.file_path).to eq(file_path)
      end
    end

    context "on load" do
      it "points to storage location" do
        loaded = Download.find(download.id)
        expect(download.file_path).to eq(Rails.root.join('downloads', loaded.id.to_s, loaded.filename))
      end
    end
  end

  describe "#destroy" do
    it "Removes the file from storage" do
      download.destroy
      expect(file_path.exist?).to be_falsey
    end
  end

end
