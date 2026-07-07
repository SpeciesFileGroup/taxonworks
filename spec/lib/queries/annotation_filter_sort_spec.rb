require 'rails_helper'

# Smoke coverage for the 10 annotation-backed filter classes exposed via the
# `browse_annotations` task. Each backend's `sortable_columns_index` is
# whitelisted to the frontend; this spec makes sure the entries actually
# order rows the way the frontend expects.
describe 'Annotation filter sort', type: :model do

  specify 'Tag sortable_columns_index includes expected keys' do
    keys = Queries::Tag::Filter.sortable_columns_index
    expect(keys).to include('id', 'tag_object_type', 'created_at', 'created_by', 'keyword.object_tag')
  end

  specify 'Tag sort=keyword.object_tag orders by keyword name' do
    k_a = FactoryBot.create(:valid_keyword, name: 'Alpha keyword')
    k_z = FactoryBot.create(:valid_keyword, name: 'Zeta keyword')
    t_a = Tag.create!(keyword: k_a, tag_object: FactoryBot.create(:valid_otu))
    t_z = Tag.create!(keyword: k_z, tag_object: FactoryBot.create(:valid_otu))

    ids = Queries::Tag::Filter.new(sort: 'keyword.object_tag')
      .all.where(id: [t_a.id, t_z.id]).pluck(:id)
    expect(ids).to eq([t_a.id, t_z.id])
  end

  specify 'Note sort=text orders alphabetically' do
    n_a = Note.create!(text: 'Alpha', note_object: FactoryBot.create(:valid_otu))
    n_z = Note.create!(text: 'Zeta',  note_object: FactoryBot.create(:valid_otu))

    ids = Queries::Note::Filter.new(sort: 'text')
      .all.where(id: [n_a.id, n_z.id]).pluck(:id)
    expect(ids).to eq([n_a.id, n_z.id])
  end

  specify 'Confidence sortable_columns_index includes confidence_level.object_tag' do
    expect(Queries::Confidence::Filter.sortable_columns_index)
      .to include('confidence_level.object_tag')
  end

  specify 'DataAttribute sort=value orders alphabetically' do
    da_a = FactoryBot.create(:valid_data_attribute, value: 'Alpha')
    da_z = FactoryBot.create(:valid_data_attribute, value: 'Zeta')

    ids = Queries::DataAttribute::Filter.new(sort: 'value')
      .all.where(id: [da_a.id, da_z.id]).pluck(:id)
    expect(ids).to eq([da_a.id, da_z.id])
  end

  specify 'Citation sortable_columns_index includes source.cached' do
    expect(Queries::Citation::Filter.sortable_columns_index)
      .to include('source.cached')
  end

  specify 'Identifier sort=cached orders alphabetically' do
    ns = FactoryBot.create(:valid_namespace)
    i_a = Identifier::Local::CatalogNumber.create!(identifier_object: Specimen.create!, namespace: ns, identifier: '001')
    i_z = Identifier::Local::CatalogNumber.create!(identifier_object: Specimen.create!, namespace: ns, identifier: '999')

    ids = Queries::Identifier::Filter.new(sort: 'cached')
      .all.where(id: [i_a.id, i_z.id]).pluck(:id)
    expect(ids).to eq([i_a.id, i_z.id])
  end

  specify 'AlternateValue sortable_columns_index includes value/type/attribute' do
    keys = Queries::AlternateValue::Filter.sortable_columns_index
    expect(keys).to include('value', 'type', 'alternate_value_object_attribute')
  end

  specify 'Attribution sortable_columns_index includes expected keys' do
    keys = Queries::Attribution::Filter.sortable_columns_index
    expect(keys).to include('id', 'attribution_object_type', 'created_at', 'created_by')
  end

  specify 'Depiction sort=caption orders alphabetically' do
    img = FactoryBot.create(:valid_image)
    d_a = Depiction.create!(depiction_object: FactoryBot.create(:valid_otu), image: img, caption: 'Alpha cap')
    d_z = Depiction.create!(depiction_object: FactoryBot.create(:valid_otu), image: img, caption: 'Zeta cap')

    ids = Queries::Depiction::Filter.new(sort: 'caption')
      .all.where(id: [d_a.id, d_z.id]).pluck(:id)
    expect(ids).to eq([d_a.id, d_z.id])
  end

  specify 'Documentation sortable_columns_index includes document.object_tag' do
    expect(Queries::Documentation::Filter.sortable_columns_index)
      .to include('document.object_tag')
  end

  specify 'unknown sort key is silently ignored on each backend' do
    [Queries::Tag::Filter, Queries::Note::Filter, Queries::Confidence::Filter,
     Queries::DataAttribute::Filter, Queries::Citation::Filter, Queries::Identifier::Filter,
     Queries::AlternateValue::Filter, Queries::Attribution::Filter,
     Queries::Depiction::Filter, Queries::Documentation::Filter].each do |cls|
      expect { cls.new(sort: 'no_such_column').all.to_a }.not_to raise_error
    end
  end

end
