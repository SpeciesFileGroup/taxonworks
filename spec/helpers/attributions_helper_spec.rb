require 'rails_helper'

describe AttributionsHelper, type: :helper do
  let(:image) {FactoryBot.create(:valid_image)  }
  let(:p) {Person.create!(last_name: 'Jones', first_name: 'Sue')}
  let(:o) {Organization.create!(name: 'Justified Ancients of Mu Mu')}

  specify 'creator (people)' do
    Attribution.create!(attribution_object: image, creator_roles_attributes: [{person: p}])
    expect(attribution_tag(image.attribution)).to match(/Jones/)
  end

  specify 'creator (people) 1' do
    Attribution.create!(attribution_object: image, creator_roles_attributes: [{person: p}])
    expect(attribution_tag(image.attribution)).to match(/Jones/)
  end

  specify 'owner (organization)' do
    Attribution.create!(attribution_object: image, owner_roles_attributes: [{organization: o}])
    expect(attribution_tag(image.attribution)).to match(/Ancients/)
  end

  specify 'copyright_holder (organization) 1' do
    Attribution.create!(attribution_object: image, copyright_holder_roles_attributes: [{organization: o}])
    expect(attribution_tag(image.attribution)).to match(/Ancients/)
  end

end
