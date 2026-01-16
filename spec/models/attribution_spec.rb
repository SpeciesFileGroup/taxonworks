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

  specify '#batch_by_filter_scope :add, does not update existing attribution' do
    Attribution.create!(
      attribution_object: image,
      license: 'Attribution'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :add,
      params: {
        attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      }
    )

    expect(r[:updated].length).to eq(0)
    expect(r[:not_updated].length).to eq(1)
    expect(Attribution.first.license).to eq('Attribution')
    expect(Attribution.first.copyright_year).to be_nil
  end

  specify '#batch_by_filter_scope :add, fills missing year' do
    Attribution.create!(
      attribution_object: image,
      license: 'Attribution'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :add,
      params: {
        attribution: {
          copyright_year: 2018
        }
      }
    )

    expect(r[:updated].length).to eq(1)
    expect(Attribution.first.license).to eq('Attribution')
    expect(Attribution.first.copyright_year).to eq(2018)
  end

  specify '#batch_by_filter_scope :add, skips existing year' do
    Attribution.create!(
      attribution_object: image,
      license: 'Attribution',
      copyright_year: 2001
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :add,
      params: {
        attribution: {
          copyright_year: 2018
        }
      }
    )

    expect(r[:updated].length).to eq(0)
    expect(r[:not_updated].length).to eq(1)
    expect(Attribution.first.copyright_year).to eq(2001)
  end

  specify '#batch_by_filter_scope :add, appends new roles only' do
    person = FactoryBot.create(:valid_person)
    another_person = FactoryBot.create(:valid_person)
    Attribution.create!(
      attribution_object: image,
      roles_attributes: [
        {
          person_id: person.id,
          type: 'AttributionCreator'
        }
      ]
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :add,
      params: {
        attribution: {
          roles_attributes: [
            {
              person_id: person.id,
              type: 'AttributionCreator'
            },
            {
              person_id: another_person.id,
              type: 'AttributionCreator'
            }
          ]
        }
      }
    )

    expect(r[:updated].length).to eq(1)
    expect(Attribution.first.creator_roles.map(&:person_id)).to contain_exactly(
      person.id,
      another_person.id
    )
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

  specify '#batch_by_filter_scope :remove' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )
    expect(Attribution.all.count).to eq(1)

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :remove,
      params: {
        attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      }
    )
    expect(r[:updated].length).to eq(1)
    expect(Attribution.all.count).to eq(0)
  end

  specify '#batch_by_filter_scope :remove, clears license only' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication',
      copyright_year: 2018
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :remove,
      params: {
        attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      }
    )

    expect(r[:updated].length).to eq(1)
    expect(Attribution.all.count).to eq(1)
    expect(Attribution.first.license).to be_nil
    expect(Attribution.first.copyright_year).to eq(2018)
  end

  specify '#batch_by_filter_scope :remove, clears year only' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication',
      copyright_year: 2018
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :remove,
      params: {
        attribution: {
          copyright_year: 2018
        }
      }
    )

    expect(r[:updated].length).to eq(1)
    expect(Attribution.all.count).to eq(1)
    expect(Attribution.first.license).to eq('CC0 1.0 Universal (CC0 1.0) Public Domain Dedication')
    expect(Attribution.first.copyright_year).to be_nil
  end

  specify '#batch_by_filter_scope :remove, clears roles only' do
    person = FactoryBot.create(:valid_person)
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication',
      roles_attributes: [
        {
          person_id: person.id,
          type: 'AttributionCreator'
        }
      ]
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :remove,
      params: {
        attribution: {
          roles_attributes: [
            {
              person_id: person.id,
              type: 'AttributionCreator'
            }
          ]
        }
      }
    )

    expect(r[:updated].length).to eq(1)
    expect(Attribution.all.count).to eq(1)
    expect(Attribution.first.license).to eq('CC0 1.0 Universal (CC0 1.0) Public Domain Dedication')
    expect(Attribution.first.creator_roles).to be_empty
  end

  specify '#batch_by_filter_scope :remove, destroys when empty' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :remove,
      params: {
        attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      }
    )

    expect(r[:updated].length).to eq(1)
    expect(Attribution.all.count).to eq(0)
  end

  specify '#batch_by_filter_scope :remove, no criteria' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :remove,
      params: {
        attribution: {}
      }
    )

    expect(r[:errors]['no attribution criteria provided']).to eq(1)
    expect(Attribution.all.count).to eq(1)
  end

  specify '#batch_by_filter_scope :remove, by role' do
    person = FactoryBot.create(:valid_person)
    Attribution.create!(
      attribution_object: image,
      roles_attributes: [
        {
          person_id: person.id,
          type: 'AttributionCreator'
        }
      ]
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :remove,
      params: {
        attribution: {
          roles_attributes: [
            {
              person_id: person.id,
              type: 'AttributionCreator'
            }
          ]
        }
      }
    )

    expect(Attribution.all.count).to eq(0)
  end

  specify '#batch_by_filter_scope :replace' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :replace,
      params: {
        attribution: {
          license: 'Attribution'
        },
        replace_attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      }
    )
    expect(Attribution.first.license).to eq('Attribution')
  end

  specify '#batch_by_filter_scope :replace, no replace criteria' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :replace,
      params: {
        attribution: {
          license: 'Attribution'
        }
      }
    )

    expect(r[:errors]['no replace attribution criteria provided']).to eq(1)
    expect(Attribution.first.license).to eq(
      'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )
  end

  specify '#batch_by_filter_scope :replace, no replacement attribution' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    r = Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :replace,
      params: {
        replace_attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      }
    )

    expect(r[:errors]['no replacement attribution provided']).to eq(1)
    expect(Attribution.first.license).to eq(
      'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )
  end

  specify '#batch_by_filter_scope :replace, by role' do
    from_person = FactoryBot.create(:valid_person)
    to_person = FactoryBot.create(:valid_person)
    Attribution.create!(
      attribution_object: image,
      roles_attributes: [
        {
          person_id: from_person.id,
          type: 'AttributionCreator'
        }
      ]
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :replace,
      params: {
        replace_attribution: {
          roles_attributes: [
            {
              person_id: from_person.id,
              type: 'AttributionCreator'
            }
          ]
        },
        attribution: {
          roles_attributes: [
            {
              person_id: to_person.id,
              type: 'AttributionCreator'
            }
          ]
        }
      }
    )

    expect(Attribution.first.creator_roles.first.person_id).to eq(to_person.id)
  end

  specify '#batch_by_filter_scope :replace, keeps non-matching roles' do
    from_person = FactoryBot.create(:valid_person)
    to_person = FactoryBot.create(:valid_person)
    organization = FactoryBot.create(:valid_organization)
    Attribution.create!(
      attribution_object: image,
      roles_attributes: [
        {
          person_id: from_person.id,
          type: 'AttributionCopyrightHolder'
        },
        {
          organization_id: organization.id,
          type: 'AttributionCopyrightHolder'
        }
      ]
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :replace,
      params: {
        replace_attribution: {
          roles_attributes: [
            {
              person_id: from_person.id,
              type: 'AttributionCopyrightHolder'
            }
          ]
        },
        attribution: {
          roles_attributes: [
            {
              person_id: to_person.id,
              type: 'AttributionCopyrightHolder'
            }
          ]
        }
      }
    )

    holder_roles = Attribution.first.roles.where(type: 'AttributionCopyrightHolder')
    expect(holder_roles.map(&:person_id)).to include(to_person.id)
    expect(holder_roles.map(&:organization_id)).to include(organization.id)
  end

  specify '#batch_by_filter_scope :replace, async' do
    Attribution.create!(
      attribution_object: image,
      license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
    )

    q = ::Queries::Image::Filter.new(image_id: image.id)
    Attribution.batch_by_filter_scope(
      filter_query: { 'image_query' => q.params },
      mode: :replace,
      params: {
        attribution: {
          license: 'Attribution'
        },
        replace_attribution: {
          license: 'CC0 1.0 Universal (CC0 1.0) Public Domain Dedication'
        }
      },
      project_id: Project.first.id,
      user_id: User.first.id,
      async_cutoff: 0
    )

    # Before job runs, license should still be the old value
    expect(Attribution.first.license).to eq('CC0 1.0 Universal (CC0 1.0) Public Domain Dedication')

    perform_enqueued_jobs

    expect(Attribution.first.license).to eq('Attribution')
  end

end
