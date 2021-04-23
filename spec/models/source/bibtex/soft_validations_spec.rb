require 'rails_helper'

describe Source::Bibtex, type: :model, group: :sources do
  after(:all) { Source.destroy_all }
  let(:source_bibtex) { FactoryBot.build(:soft_valid_bibtex_source_article) }

  specify 'missing roles 1' do
    src = FactoryBot.build(:soft_valid_bibtex_source_article)
    src.soft_validate(only_sets: [:missing_roles])
    expect(src.soft_validations.messages_on(:base)).to include('Author roles are not selected.')
  end

  specify 'missing roles 2' do
    src = FactoryBot.build(:soft_valid_bibtex_source_article)
    src.authors << FactoryBot.create(:valid_person)
    src.soft_validate(only_sets: [:missing_roles])
    expect(src.soft_validations.messages_on(:base)).to_not include('Author roles are not selected.')
  end

  specify '#publisher' do
    s = ::Source::Bibtex.new(bibtex_type: 'book')
    s.soft_validate(only_methods: [:sv_has_publisher])
    expect(s.soft_validations.messages_on(:publisher).empty?).to be_falsey
  end

  specify '#year 1' do
    source_bibtex.update(year: 2000)
    source_bibtex.soft_validate
    expect(source_bibtex.soft_validations.messages_on(:year).empty?).to be_truthy
  end

  specify '#year 2' do
    source_bibtex.update(year: 999)
    source_bibtex.soft_validate
    expect(source_bibtex.soft_validations.messages).to include 'This year is prior to the 1700s.'
  end

  specify 'missing authors 1' do
    source_bibtex.soft_validate(only_methods: [:sv_has_authors])
    expect(source_bibtex.soft_validations.messages_on(:base).empty?).to be_truthy
  end

  specify 'missing authors 2' do
    source_bibtex.update(author: nil)
    source_bibtex.soft_validate(only_methods: [:sv_has_authors])
    expect(source_bibtex.soft_validations.messages).to include('Valid BibTeX requires an author for this type of source.')
  end

  specify 'unpublished sources require a note 1' do
    source_bibtex.bibtex_type = 'unpublished'
    source_bibtex.soft_validate
    expect(source_bibtex.soft_validations.messages).to include 'Valid BibTeX requires a note with an unpublished source.'
  end

  specify 'unpublished sources require a note 2' do
    source_bibtex.update(note:  'test note 1.')
    source_bibtex.soft_validate
    expect(source_bibtex.soft_validations.messages_on(:note).empty?).to be_truthy
  end



end
