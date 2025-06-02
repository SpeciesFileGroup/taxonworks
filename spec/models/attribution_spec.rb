require 'rails_helper'

RSpec.describe Attribution, type: :model do
  include ActiveJob::TestHelper

  let(:attribution) { Attribution.new }
  let(:image) { FactoryBot.create(:valid_image) }

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
      async_cutoff: 0
    )
    expect(Attribution.all.count).to eq(0)

    perform_enqueued_jobs

    expect(Attribution.all.count).to eq(1)
  end

end
