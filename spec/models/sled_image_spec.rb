require 'rails_helper'

RSpec.describe SledImage, type: :model, group: :image do

  let(:sled_image) { SledImage.new }
  let(:image) { FactoryBot.create(:valid_image) }

  let(:metadata) {
    [
      {
        "index": 0,
        "upperCorner": {"x":0, "y":0},
        "lowerCorner": {"x":2459.5, "y":1700.75},
        "row": 0,
        "column": 0
      },
      {
        "index":1,
        "upperCorner": {"x":2459.5,"y":0},
        "lowerCorner":{"x":3689.25, "y":1700.75},
        "row": 0,
        "column": 1
      },
      {
        "index": 2,
        "upperCorner":{"x":3689.25, "y":0},
        "lowerCorner":{"x":4919, "y":1700.75},
        "row": 0,
        "column": 2
      },
      {
        "index": 3,
        "upperCorner":{"x":0, "y":1700.75},
        "lowerCorner":{"x":2459.5, "y":3401.5},
        "row": 1,
        "column": 0
      },
      {
        "index": 4,
        "upperCorner":{"x":2459.5, "y":1700.75},
        "lowerCorner":{"x":3689.25, "y":3401.5},
        "row": 1,
        "column": 1
      },
      {
        "index": 5,
        "upperCorner":{"x":3689.25, "y":1700.75},
        "lowerCorner":{"x":4919, "y":3401.5},
        "row": 1,
        "column": 2
      },
      {
        "index": 6,
        "upperCorner":{"x":0, "y":3401.5},
        "lowerCorner":{"x":2459.5, "y":6803},
        "row": 2,
        "column": 0
      },
      {
        "index": 7,
        "upperCorner":{"x":2459.5, "y":3401.5},
        "lowerCorner":{"x":3689.25, "y":6803},
        "row": 2,
        "column": 1
      },
      {
        "index": 8,
        "upperCorner":{"x":3689.25, "y":3401.5},
        "lowerCorner":{"x":4919, "y":6803},
        "row": 2,
        "column": 2
      }]}

  let(:namespace) { FactoryBot.create(:valid_namespace) }
  let(:keyword) { FactoryBot.create(:valid_keyword) }
  let(:otu) { FactoryBot.create(:valid_otu) } 

  let(:collection_object_params) {
    {
      total: 1,
      identifiers_attributes: [ {identifier: 0, type: 'Identifier::Local::CatalogNumber', namespace_id: namespace.id} ] ,
      notes_attributes: [ { text: 'Hello' } ],
      tags_attributes: [ { keyword_id: keyword.id } ],
      taxon_determinations_attributes: [ { otu_id: otu.id} ]
    }}

  context '#summary' do
    before do
      sled_image.update!(
        metadata: metadata,
        image: image,
        collection_object_params: collection_object_params
      )
    end

    specify 'depiction_id' do
      expect(sled_image.summary[0][0].dig(:depiction_id)).to be_truthy
    end

    specify 'collection_object_id' do
      expect(sled_image.summary[0][0].dig(:collection_object_id)).to be_truthy
    end

    specify 'identifier' do
      expect(sled_image.summary[0][0].dig(:identifier)).to be_truthy
    end

  end

  context 'writing objects' do
    before do
      sled_image.update!(
        metadata: metadata,
        image: image,
        collection_object_params: collection_object_params,
      )
    end

    specify 'collection_objects' do
      expect(CollectionObject.all.count).to eq(9)
    end

    specify 'identifiers' do
      expect(Identifier.all.count).to eq(9)
    end

    specify 'notes' do
      expect(Note.all.count).to eq(9)
    end

    specify 'depictions' do
      expect(Depiction.where(sled_image: sled_image).all.count).to eq(9)
    end

    specify 'taxon_determinations' do
      expect(TaxonDetermination.all.count).to eq(9)
    end

    specify 'tags' do
      expect(Tag.all.count).to eq(9)
    end

    specify '#collection_objects' do
      expect(sled_image.collection_objects.count).to eq(9)
    end

    specify '#depictions' do
      expect(sled_image.depictions.count).to eq(9)
    end

    specify '#destroy' do
      sled_image.nuke = 'nuke'
      sled_image.destroy
      expect(CollectionObject.all.reload.count).to eq(0)
    end
  end

  context 'existing objects/identifiers' do
    let!(:oe) { Specimen.create!(identifiers_attributes: [{type: 'Identifier::Local::CatalogNumber', namespace_id: namespace.id, identifier: 0}]) }

    before do
      sled_image.update!(
        metadata: metadata,
        image: image,
        collection_object_params: collection_object_params
      )
    end

    specify 'depictions' do
      expect(oe.depictions.reload.count).to eq(1)
    end

    # Are not added!
    specify 'notes' do
      expect(oe.notes.reload.count).to eq(0)
    end

    # Are not added!
    specify 'tags' do
      expect(oe.tags.reload.count).to eq(0)
    end

    # Are not added!
    specify 'taxon_determinations' do
      expect(oe.taxon_determinations.reload.count).to eq(0)
    end
  end

  specify '#new_collection_object' do
    sled_image.collection_object_params = collection_object_params
    expect(sled_image.send(:new_collection_object)).to be_truthy
  end

  context '_identifier_matrix' do
    before do
      sled_image.metadata = metadata
      sled_image.collection_object_params = collection_object_params
    end

    specify 'by row' do
      sled_image.step_identifier_on = 'row'
      expect(sled_image.send(:_identifier_matrix)).to contain_exactly([0,1,2], [3,4,5], [6,7,8])
    end

    specify 'by column' do
      sled_image.step_identifier_on = 'column'
      expect(sled_image.send(:_identifier_matrix)).to contain_exactly([0,3,6], [1,4,7], [2,5,8])
    end

    specify 'by column, gaps 1' do
      sled_image.step_identifier_on = 'column'
      sled_image.metadata[0]['metadata'] = 'foo'
      sled_image.metadata[8]['metadata'] = 'foo'
      expect(sled_image.send(:_identifier_matrix)).to contain_exactly([nil,2,5], [0,3,6], [1,4, nil])
    end

    specify 'by column, gaps 2' do
      sled_image.step_identifier_on = 'column'
      sled_image.metadata[1]['metadata'] = 'foo'
      sled_image.metadata[4]['metadata'] = 'foo'

      expect(sled_image.send(:_identifier_matrix)).to contain_exactly([0,nil,4], [1,nil,5], [2,3,6])
    end

    specify 'by row, gaps 2' do
      sled_image.step_identifier_on = 'row'
      sled_image.metadata[3]['metadata'] = 'foo'
      sled_image.metadata[4]['metadata'] = 'foo'
      expect(sled_image.send(:_identifier_matrix)).to contain_exactly([0,1,2], [nil,nil, 3], [4,5,6])
    end

    specify '#identifier_for 1' do
      sled_image.step_identifier_on = 'column'
      expect(sled_image.send(:identifier_for, sled_image.metadata[0] )).to eq(0)
    end

    specify '#identifier_for 2' do
      sled_image.step_identifier_on = 'column'
      expect(sled_image.send(:identifier_for, sled_image.metadata[2]) ).to eq(6)
    end

    specify 'starting from non 0' do
      sled_image.step_identifier_on = 'row'
      sled_image.collection_object_params[:identifiers_attributes][0][:identifier] = 997
      expect(sled_image.send(:_identifier_matrix)).to contain_exactly([997,998,999], [1000,1001,1002], [1003,1004,1005])
    end
  end

  specify '#depiction_params / #is_metadata_depiction?' do
    sled_image.update(metadata: [], image: image, depiction_params: {is_metadata_depiction: 'true'})
    expect(sled_image.send(:is_metadata_depiction?)).to eq(true)
  end

  specify '#metadata (update, Array)' do
    sled_image.update(metadata: [], image: image)
    expect(sled_image.metadata).to eq([])
  end

  specify '#metadata= (String)' do
    sled_image.metadata= '[]'
    expect(sled_image.metadata).to eq([])
  end

  specify '#metadata (update, String)' do
    expect(sled_image.update(metadata: '[]', image: image)).to be_truthy
    expect(sled_image.metadata).to eq([])
  end

  specify 'validates' do
    sled_image.image = image
    sled_image.metadata = []
    expect(sled_image.valid?).to be_truthy
  end

  specify 'cached values' do
    sled_image.update(image: image, metadata: [])
    expect(sled_image.cached_total_collection_objects).to eq(0)
  end

  specify 'cached values' do
    sled_image.update(image: image, metadata: [])
    expect(sled_image.cached_total_rows).to eq(nil)
  end

  specify 'cached values' do
    sled_image.update(image: image, metadata: [])
    expect(sled_image.cached_total_columns).to eq(nil)
  end

  specify '#image' do
    expect(sled_image.image = Image.new).to be_truthy
  end

  context '#metadata' do
    before { sled_image.metadata = metadata }

    specify '#total_metadata_objects' do
      expect(sled_image.send(:total_metadata_objects)).to eq(9)
    end

    specify '#svg_clip' do
      expect(sled_image.send(:svg_clip, sled_image.metadata[0] )).to eq('<rect x="0.0" y="0.0" width="2459.5" height="1700.75" />')
    end

    specify '#view_box' do
      expect(sled_image.send(:svg_view_box, sled_image.metadata[0] )).to eq('0.0 0.0 2459.5 1700.75')
    end

    specify '#total("rows")' do
      expect(sled_image.total("row")).to eq(2)
    end

    specify '#total("columns")' do
      expect(sled_image.total("column")).to eq(2)
    end
  end

end
