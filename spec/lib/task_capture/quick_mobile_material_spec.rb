require 'rails_helper'

describe TaskCapture::QuickMobileMaterial, type: :model, group: [:images, :collection_objects] do
  let(:composition) { FactoryBot.create(:valid_layout_task) }
  let(:namespace) { FactoryBot.create(:valid_namespace) }
  let(:repository) { FactoryBot.create(:valid_repository) }

  let(:png) { Rails.root.join('spec/files/images/tiny.png') }
  let(:other_png) { Spec::Support::Utilities::Files.generate_tiny_random_png }

  def upload(path = png)
    Rack::Test::UploadedFile.new(path, 'image/png')
  end

  def capture(**params)
    TaskCapture::QuickMobileMaterial.new(
      composition_id: composition.id,
      repository_id: params.key?(:repository_id) ? params.delete(:repository_id) : repository.id,
      namespace_id: params.key?(:namespace_id) ? params.delete(:namespace_id) : namespace.id,
      params: { image: upload }.merge(params)
    ).call
  end

  context 'missing or invalid image' do
    specify '422 without an image' do
      r = capture(image: nil)
      expect(r.status).to eq(:unprocessable_content)
      expect(r.body.keys).to eq([:errors])
    end

    specify '422 for an invalid image, saves nothing' do
      r = capture(image: Rack::Test::UploadedFile.new(Rails.root.join('spec/files/images/very_tiny.png'), 'image/png'))
      expect(r.status).to eq(:unprocessable_content)
      expect(CollectionObject.count).to eq(0)
    end
  end

  context 'step 4, create' do
    let!(:r) { capture(catalog_number: '0001', text: 'USA: IL, Champaign') }
    let(:co) { CollectionObject.find(r.body[:collection_object_id]) }

    specify 'result is created' do
      expect(r.status).to eq(:ok)
      expect(r.body[:result]).to eq('created')
    end

    specify 'creates a CollectionObject with the Repository from the token' do
      expect(co.repository).to eq(repository)
    end

    specify 'text maps to buffered_collecting_event' do
      expect(co.buffered_collecting_event).to eq('USA: IL, Champaign')
    end

    specify 'creates the CatalogNumber in the token Namespace' do
      cn = co.identifiers.where(type: 'Identifier::Local::CatalogNumber').first
      expect(cn.identifier).to eq('0001')
      expect(cn.namespace).to eq(namespace)
      expect(r.body[:catalog_number]).to eq({ identifier_id: cn.id, namespace_id: namespace.id, identifier: '0001' })
    end

    specify 'creates an Image and a Depiction of the CollectionObject' do
      d = Depiction.find(r.body[:depiction_id])
      expect(d.depiction_object).to eq(co)
      expect(d.image_id).to eq(r.body[:image_id])
    end

    specify 'returns the Image fingerprint as image_md5' do
      expect(r.body[:image_md5]).to eq(Image.find(r.body[:image_id]).image_file_fingerprint)
      expect(r.body[:image_md5]).to eq(Digest::MD5.file(png).hexdigest)
    end

    specify 'appends a TaskItem' do
      i = CompositionItem.find(r.body[:composition_item_id])
      expect(i).to be_a(LayoutItem::TaskItem)
      expect(i.composition_item_object).to eq(co)
      expect(i.composition_id).to eq(composition.id)
    end

    specify 'nothing ignored' do
      expect(r.body[:ignored]).to eq([])
      expect(r.body[:warnings]).to eq([])
    end

    specify 'new TaskItems go to the bottom' do
      r2 = capture(image: upload(other_png))
      expect(CompositionItem.find(r2.body[:composition_item_id]).position).to be > CompositionItem.find(r.body[:composition_item_id]).position
    end
  end

  specify 'step 4 without a catalog number or Namespace' do
    r = capture(namespace_id: nil, repository_id: nil)
    expect(r.body[:result]).to eq('created')
    expect(r.body[:catalog_number]).to be_nil
  end

  context 'step 1, retry by Image fingerprint' do
    let!(:first) { capture(catalog_number: '0001') }

    specify 'same Image in this Composition is a duplicate, returns the original metadata, creates nothing' do
      counts = [CollectionObject.count, Image.count, Depiction.count, CompositionItem.count, Identifier.count]
      r = capture(catalog_number: '0001')
      expect(r.status).to eq(:ok)
      expect(r.body[:result]).to eq('duplicate')
      expect(r.body.except(:result)).to eq(first.body.except(:result))
      expect([CollectionObject.count, Image.count, Depiction.count, CompositionItem.count, Identifier.count]).to eq(counts)
    end

    specify 'same Image already in the Project, not in this Composition, is 422' do
      CompositionItem.delete_all
      r = capture
      expect(r.status).to eq(:unprocessable_content)
    end
  end

  context 'step 2, append to collection_object_id' do
    let!(:first) { capture(catalog_number: '0001') }
    let(:co_id) { first.body[:collection_object_id] }

    specify 'appends a new Image' do
      r = capture(image: upload(other_png), collection_object_id: co_id)
      expect(r.body[:result]).to eq('appended')
      expect(r.body[:collection_object_id]).to eq(co_id)
      expect(Depiction.where(depiction_object_id: co_id).count).to eq(2)
      expect(r.body[:composition_item_id]).to eq(first.body[:composition_item_id])
      expect(CompositionItem.count).to eq(1)
    end

    specify 'text is ignored' do
      r = capture(image: upload(other_png), collection_object_id: co_id, text: 'foo')
      expect(r.body[:ignored]).to eq(['text'])
      expect(CollectionObject.find(co_id).buffered_collecting_event).to be_nil
    end

    specify 'a matching catalog_number is fine' do
      r = capture(image: upload(other_png), collection_object_id: co_id, catalog_number: '0001')
      expect(r.body[:result]).to eq('appended')
      expect(r.body[:ignored]).to eq([])
    end

    specify 'a differing catalog_number is 422, saves nothing' do
      n = Image.count
      r = capture(image: upload(other_png), collection_object_id: co_id, catalog_number: '0002')
      expect(r.status).to eq(:unprocessable_content)
      expect(Image.count).to eq(n)
    end

    specify 'a catalog_number on a CollectionObject without one is ignored' do
      bare = capture(image: upload(other_png), namespace_id: nil)
      r = capture(image: upload(Spec::Support::Utilities::Files.generate_tiny_random_png), collection_object_id: bare.body[:collection_object_id], catalog_number: '0009')
      expect(r.body[:result]).to eq('appended')
      expect(r.body[:ignored]).to eq(['catalog_number'])
      expect(r.body[:catalog_number]).to be_nil
    end

    specify 'an unknown collection_object_id is 422' do
      r = capture(image: upload(other_png), collection_object_id: 0)
      expect(r.status).to eq(:unprocessable_content)
    end

    specify 'a CollectionObject not in this Composition is 422' do
      co = FactoryBot.create(:valid_collection_object)
      r = capture(image: upload(other_png), collection_object_id: co.id)
      expect(r.status).to eq(:unprocessable_content)
    end

    specify 'a CollectionObject in another Project is 422' do
      p2 = FactoryBot.create(:valid_project, without_root_taxon_name: true)
      CollectionObject.where(id: co_id).update_all(project_id: p2.id)
      r = capture(image: upload(other_png), collection_object_id: co_id)
      expect(r.status).to eq(:unprocessable_content)
    end
  end

  context 'step 3, catalog_number without collection_object_id' do
    specify 'no Namespace in the token settings is 422' do
      r = capture(catalog_number: '0001', namespace_id: nil)
      expect(r.status).to eq(:unprocessable_content)
      expect(CollectionObject.count).to eq(0)
    end

    context 'the CatalogNumber exists' do
      let(:co) { FactoryBot.create(:valid_collection_object) }
      let!(:cn) { Identifier::Local::CatalogNumber.create!(identifier_object: co, namespace:, identifier: '0001') }

      specify 'matches the CollectionObject rather than creating one' do
        r = capture(catalog_number: '0001', text: 'foo')
        expect(r.body[:result]).to eq('matched')
        expect(r.body[:collection_object_id]).to eq(co.id)
        expect(r.body[:ignored]).to eq(['text'])
        expect(r.body[:catalog_number]).to eq({ identifier_id: cn.id, namespace_id: namespace.id, identifier: '0001' })
        expect(CollectionObject.count).to eq(1)
      end

      specify 'appends a TaskItem when not already in this Composition' do
        r = capture(catalog_number: '0001')
        expect(CompositionItem.find(r.body[:composition_item_id]).composition_item_object).to eq(co)
      end

      specify 'sequential identical catalog numbers match the current CollectionObject' do
        r1 = capture(catalog_number: '0001')
        r2 = capture(image: upload(other_png), catalog_number: '0001')
        expect(r2.body[:result]).to eq('matched')
        expect(r2.body[:composition_item_id]).to eq(r1.body[:composition_item_id])
        expect(CompositionItem.count).to eq(1)
        expect(Depiction.where(depiction_object: co).count).to eq(2)
      end
    end

    specify 'a CatalogNumber on something other than a CollectionObject is 422' do
      c = FactoryBot.create(:valid_container)
      Identifier::Local::CatalogNumber.create!(identifier_object: c, namespace:, identifier: '0001')
      r = capture(catalog_number: '0001')
      expect(r.status).to eq(:unprocessable_content)
      expect(CollectionObject.count).to eq(0)
    end
  end

  context 'catalog_number including the Namespace (as on a label)' do
    let(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'INHS', verbatim_short_name: nil) }

    specify 'the Namespace is split off on create' do
      r = capture(catalog_number: 'INHS 122345')
      cn = Identifier::Local::CatalogNumber.find(r.body[:catalog_number][:identifier_id])
      expect(cn.identifier).to eq('122345')
      expect(cn.cached).to eq('INHS 122345')
      expect(r.body[:warnings]).to eq([])
    end

    specify 'the verbatim_short_name is split off' do
      namespace.update!(short_name: 'INHS2', verbatim_short_name: 'INHS')
      r = capture(catalog_number: 'inhs:122345')
      expect(r.body[:catalog_number][:identifier]).to eq('122345')
    end

    specify 'matches an existing CatalogNumber' do
      co = FactoryBot.create(:valid_collection_object)
      Identifier::Local::CatalogNumber.create!(identifier_object: co, namespace:, identifier: '122345')
      r = capture(catalog_number: 'INHS 122345')
      expect(r.body[:result]).to eq('matched')
      expect(r.body[:collection_object_id]).to eq(co.id)
    end

    specify 'compares on append' do
      first = capture(catalog_number: '122345')
      r = capture(image: upload(other_png), collection_object_id: first.body[:collection_object_id], catalog_number: 'INHS 122345')
      expect(r.body[:result]).to eq('appended')
    end

    specify 'an apparent other Namespace is kept whole, with a warning' do
      r = capture(catalog_number: 'FMNH 1')
      expect(r.body[:catalog_number][:identifier]).to eq('FMNH 1')
      expect(r.body[:warnings].first).to match(/FMNH/)
    end

    specify 'a virtual Namespace is never split off' do
      namespace.update!(is_virtual: true)
      r = capture(catalog_number: 'INHS 122345')
      expect(r.body[:catalog_number][:identifier]).to eq('INHS 122345')
      expect(r.body[:warnings]).to eq([])
    end
  end

  context 'ignored params' do
    after { Rails.cache.clear }

    specify 'are recorded for the TaskItem, so the Task can flag the row' do
      first = capture
      capture(image: upload(other_png), collection_object_id: first.body[:collection_object_id], text: 'foo', catalog_number: '0001')
      expect(TaskCapture::QuickMobileMaterial.ignored_for([first.body[:composition_item_id]]))
        .to eq({ first.body[:composition_item_id] => ['catalog_number', 'text'] })
    end

    specify 'are not recorded when nothing is ignored' do
      r = capture
      expect(TaskCapture::QuickMobileMaterial.ignored_for([r.body[:composition_item_id]])).to eq({})
    end
  end

  specify 'failure bodies carry no ids' do
    r = capture(collection_object_id: 0)
    expect(r.body.keys).to eq([:errors])
    expect(r.body[:errors]).to be_present
  end
end
