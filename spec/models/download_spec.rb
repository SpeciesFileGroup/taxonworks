require 'rails_helper'

RSpec.describe Download, type: :model do
  # TODO: Avoid having to merge file_path when factory already provides this
  let(:valid_attributes) { 
    strip_housekeeping_attributes(FactoryBot.build(:valid_download).attributes.merge({ source_file_path: Rails.root.join('spec/files/downloads/Sample.zip') }))
  }

  let(:download) { Download.create! valid_attributes }
  let(:file_path) { Download.storage_path.join(*download.id.to_s.rjust(9, '0').scan(/.../), download.filename) }

  describe "default scope" do
    let(:expiry_dates) { [1.day.ago, 2.day.ago, 1.minute.from_now, 1.day.from_now, 1.week.from_now] }

    before do
      expiry_dates.each do | time |
        Download.create! valid_attributes.merge({ expires: time })
      end
    end

    it "returns non-expired downloads only" do
      expect(Download.all.count).to eq(3)
    end

    it "can be avoided with 'unscoped'" do
      expect(Download.unscoped.all.count).to eq(5)
    end
  end

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
        expect(download.file_path).to eq(Download.storage_path.join(*loaded.id.to_s.rjust(9, '0').scan(/.../), loaded.filename))
      end
    end

    describe "directory structure" do
      it "is three-level deep composed of the zero-padded id split in groups of three (id < 10^9)" do
        download = Download.new(valid_attributes)
        download.id = 1234567
        download.save!

        expect(download.file_path).to eq(Download.storage_path.join('001', '234', '567', download.filename))
      end

      xit "outermost directory is longer than the others when id >= 10^9" do
        download = Download.new(valid_attributes)
        download.id = 1234567890
        download.save!

        expect(download.file_path).to eq(Download.storage_path.join('1234', '567', '890', download.filename))
      end
    end
  end

  describe "#expired?" do
    it "is true when expire date is lower than current time" do
      download.expires = 1.second.ago

      expect(download.expired?).to be_truthy
    end

    it "is false when expire is date is higher or equal to current time" do
      download.expires = 1.day.from_now

      expect(download.expired?).to be_falsey
    end
  end

  describe "#destroy" do
    it "Removes the file from storage" do
      download.destroy
      expect(file_path.exist?).to be_falsey
    end
  end

end
