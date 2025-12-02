require 'rails_helper'

RSpec.describe Attribution, type: :model do
  include ActiveJob::TestHelper

  let(:attribution) { Attribution.new }
  let(:image) { FactoryBot.create(:valid_image) }

  let(:organization) { FactoryBot.create(:valid_organization) }

  specify 'some_data_required' do
    attribution.attribution_object = image
    expect(attribution.valid?).to be_falsey
  end

  specify 'some_data_required 1' do
    attribution.attribution_object = image
    attribution.license = 'Attribution'
    expect(attribution.valid?).to be_truthy
  end

  specify 'some_data_required 2' do
    attribution.attribution_object = image
    attribution.license = 'Attribution'
    attribution.save!
    expect(attribution.update(license: nil)).to be_falsey
  end

  specify 'some_data_required 3' do
    attribution.attribution_object = image
    attribution.license = 'Attribution'
    attribution.save!
    expect(attribution.update(license: nil)).to be_falsey
  end

  specify 'some_data_required 4' do
    attribution.attribution_object = image
    attribution.license = 'Attribution'
    attribution.copyright_year = '1930'
    attribution.save!
    expect(attribution.update(license: nil)).to be_truthy
  end

  specify 'some_data_required 5' do
    attribution.update!(
      attribution_object: image,
      copyright_year: '1930'
    )
    expect(attribution.update!(
      copyright_year: nil,
      attribution_organization_copyright_holders: [organization],
    )).to be_truthy
  end

  specify 'organization copyright holders 1' do
    attribution.update!(
      attribution_organization_copyright_holders: [organization],
      attribution_object: image,
    )
    expect(attribution.update!(
      copyright_year: '1940',
    )).to be_truthy
  end

  specify 'organization copyright holders 1' do
    expect(attribution.update!(
      attribution_object: image,
      roles_attributes: [
        { organization_id: organization.id,
         type: 'AttributionCopyrightHolder'
        }
      ]
    )).to be_truthy
  end

  specify 'can not be built nested and invalid' do
    a = FactoryBot.create(:valid_attribution)
    b = FactoryBot.build(:valid_attribution, attribution_object: a.attribution_object)
    expect(b.valid?).to be_falsey
  end

  specify 'unique to object' do
    a = FactoryBot.create(:valid_attribution)
    b = FactoryBot.build(:valid_attribution, attribution_object: a.attribution_object)
    expect(b.valid?).to be_falsey
  end

  specify '#license' do
    attribution.license = 'foo'
    attribution.valid?
    expect(attribution.errors.include?(:license)).to be_truthy
  end

  specify '#copyright_year 1' do
    attribution.copyright_year = '1'
    attribution.valid?
    expect(attribution.errors.include?(:copyright_year)).to be_truthy
  end

  specify '#copyright_year 2' do
    attribution.copyright_year = '1984'
    attribution.valid?
    expect(attribution.errors.include?(:copyright_year)).to be_falsey
  end

  specify '#attribution_object_type' do
    attribution.attribution_object_type = ''
    attribution.save
    expect(attribution.attribution_object_type).to eq(nil)
  end

  specify '#batch_by_filter_scope :add' do
    q = ::Queries::Image::Filter.new(image_id: image.id)
    Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :add,
      params: {
        attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      }
    )
    expect(Attribution.all.count).to eq(1)
  end

  specify '#batch_by_filter_scope :add, async' do
    q = ::Queries::Image::Filter.new(image_id: image.id)
    Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :add,
      params: {
        attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      },
      project_id: Project.first.id,
      user_id: User.first.id,
      async_cutoff: 0
    )
    expect(Attribution.all.count).to eq(0)

    perform_enqueued_jobs

    expect(Attribution.all.count).to eq(1)
  end

end
