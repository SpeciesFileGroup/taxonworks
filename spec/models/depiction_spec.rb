require 'rails_helper'

RSpec.describe Depiction, type: :model do
 let(:depiction) { Depiction.new() }
 let(:image_file) { fixture_file_upload((Rails.root + 'spec/files/images/tiny.png'), 'image/png')  }
 let(:specimen) { FactoryGirl.create(:valid_specimen) } 

 specify 'new depiction also creates new (nested) image' do
    depiction.image_attributes = {image_file: image_file }
    depiction.depiction_object = specimen
    expect(depiction.save).to be_truthy
 
    expect(depiction.image.reload).to be_truthy
 end


end
