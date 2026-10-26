require 'rails_helper'

# Precedence between a valid status (TaxonNameClassification::Iczn::Available::Valid)
# and an invalidating TaxonNameRelationship (a synonym) asserted on the same name.
#
# When both the status and the relationship are cited, the most recently
# published assertion determines validity. The date of an assertion is the
# latest nomenclature date among its citations.
#
# When either assertion is uncited, publication order can not be determined,
# and the valid status takes precedence.
describe TaxonName, type: :model, group: [:nomenclature] do

  let(:genus) { FactoryBot.create(:relationship_genus) }
  let(:junior) { FactoryBot.create(:relationship_species, name: 'aus', parent: genus) }
  let(:senior) { FactoryBot.create(:relationship_species, name: 'bus', parent: genus) }
  let(:other_senior) { FactoryBot.create(:relationship_species, name: 'cus', parent: genus) }

  def source_published(year, month: nil, day: nil)
    FactoryBot.create(:valid_source_bibtex, title: "Published #{year} #{month} #{day}", year:, month:, day:)
  end

  def add_citations(object, sources)
    sources.drop(1).each do |s|
      Citation.create!(citation_object: object, source: s)
    end
    object
  end

  def add_valid_status(taxon_name, *sources)
    c = TaxonNameClassification::Iczn::Available::Valid.create!(taxon_name:, source: sources.first)
    add_citations(c, sources)
  end

  def add_synonym(subject, object, *sources)
    r = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: subject, object_taxon_name: object, source: sources.first)
    add_citations(r, sources)
  end

  shared_examples 'the valid status takes precedence' do
    specify '#unavailable_or_invalid?' do
      expect(junior.reload.unavailable_or_invalid?).to be_falsey
    end

    specify '#get_valid_taxon_name' do
      expect(junior.reload.get_valid_taxon_name).to eq(junior)
    end

    specify '#cached_is_valid' do
      expect(junior.reload.cached_is_valid).to be_truthy
    end

    specify '#cached_valid_taxon_name_id' do
      expect(junior.reload.cached_valid_taxon_name_id).to eq(junior.id)
    end
  end

  shared_examples 'the invalidating relationship takes precedence' do |valid_name_method = :senior|
    specify '#unavailable_or_invalid?' do
      expect(junior.reload.unavailable_or_invalid?).to be_truthy
    end

    specify '#get_valid_taxon_name' do
      expect(junior.reload.get_valid_taxon_name).to eq(send(valid_name_method))
    end

    specify '#cached_is_valid' do
      expect(junior.reload.cached_is_valid).to be_falsey
    end

    specify '#cached_valid_taxon_name_id' do
      expect(junior.reload.cached_valid_taxon_name_id).to eq(send(valid_name_method).id)
    end
  end

  context 'Valid status cited, synonym cited' do
    context 'status published after synonym' do
      before do
        add_synonym(junior, senior, source_published(1950))
        add_valid_status(junior, source_published(1970))
      end

      include_examples 'the valid status takes precedence'
    end

    context 'synonym published after status' do
      before do
        add_valid_status(junior, source_published(1950))
        add_synonym(junior, senior, source_published(1970))
      end

      include_examples 'the invalidating relationship takes precedence'
    end

    context 'same year, status published in a later month' do
      before do
        add_synonym(junior, senior, source_published(1970, month: 'mar'))
        add_valid_status(junior, source_published(1970, month: 'oct'))
      end

      include_examples 'the valid status takes precedence'
    end

    context 'same year, synonym published in a later month' do
      before do
        add_valid_status(junior, source_published(1970, month: 'mar'))
        add_synonym(junior, senior, source_published(1970, month: 'oct'))
      end

      include_examples 'the invalidating relationship takes precedence'
    end

    context 'same publication date' do
      before do
        add_valid_status(junior, source_published(1970, month: 'mar', day: 1))
        add_synonym(junior, senior, source_published(1970, month: 'mar', day: 1))
      end

      include_examples 'the valid status takes precedence'
    end
  end

  context 'Valid status cited, synonym uncited' do
    before do
      add_synonym(junior, senior)
      add_valid_status(junior, source_published(1970))
    end

    include_examples 'the valid status takes precedence'
  end

  context 'Valid status uncited, synonym cited' do
    before do
      add_valid_status(junior)
      add_synonym(junior, senior, source_published(1970))
    end

    include_examples 'the valid status takes precedence'
  end

  context 'Valid status uncited, synonym uncited' do
    before do
      add_valid_status(junior)
      add_synonym(junior, senior)
    end

    include_examples 'the valid status takes precedence'
  end

  context 'validity asserted more than once (e.g. ScaleNet histories)' do
    context 'synonym 1950, status 1970, same synonym repeated 1990' do
      before do
        add_synonym(junior, senior, source_published(1950), source_published(1990))
        add_valid_status(junior, source_published(1970))
      end

      include_examples 'the invalidating relationship takes precedence'
    end

    context 'synonym 1950, status 1970, synonym repeated 1990, status repeated 2010' do
      before do
        add_synonym(junior, senior, source_published(1950), source_published(1990))
        add_valid_status(junior, source_published(1970), source_published(2010))
      end

      include_examples 'the valid status takes precedence'
    end

    context 'synonym of one name 1950, status 1970, synonym of another name 1990' do
      before do
        add_synonym(junior, senior, source_published(1950))
        add_valid_status(junior, source_published(1970))
        add_synonym(junior, other_senior, source_published(1990))
      end

      include_examples 'the invalidating relationship takes precedence', :other_senior
    end

    context 'synonym 1950 and 1990, status uncited' do
      before do
        add_synonym(junior, senior, source_published(1950), source_published(1990))
        add_valid_status(junior)
      end

      include_examples 'the valid status takes precedence'
    end
  end
end
