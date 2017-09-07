require 'rails_helper'

describe 'HasPapertrail', type: :model, versioning: true do
  let(:class_with_papertrail) {TestHasPapertrail.create!(string: 'ABC')}

  specify 'has many #versions' do
    expect(class_with_papertrail).to respond_to(:versions)
  end

  specify 'does not create a version on create' do
    expect(class_with_papertrail.versions.count == 0).to be_truthy 
  end

  specify 'does not create a version on destroy' do
    class_with_papertrail.destroy
    expect(PaperTrail::Version.all.count).to eq(0)
  end

  specify 'on update a version is created' do
    class_with_papertrail.update(string: 'DEF')
    class_with_papertrail.save!
    expect(class_with_papertrail.versions.count).to eq(1)
  end
end

class TestHasPapertrail < ApplicationRecord
  include FakeTable
  include Shared::HasPapertrail
end

