require 'rails_helper'

describe Source, type: :model, group: :source do

  let(:source) { Source.new }

  after(:all) {
    Source.destroy_all
  }

  specify '#is_in_project? 1' do
    expect(source.is_in_project?(1)).to be_falsey
  end

  context 'associations' do
    specify '#citations' do
      expect(source.citations << Citation.new()).to be_truthy
    end
  end

  context 'cited objects' do
    let(:o) { FactoryBot.create(:valid_otu) }
    let(:a) { FactoryBot.create(:valid_source_bibtex) }

    specify 'returns a scope' do
      expect(source.cited_objects).to eq([])
    end

    specify 'returns a mixed array of objects' do
      Citation.create!(source: a, citation_object: o)
      a.reload
      expect(a.cited_objects.include?(o)).to be_truthy
    end
  end

  context 'concerns matching' do
    let(:string1) { 'This is a base string.' }
    let!(:s1) { FactoryBot.create(:valid_source_verbatim, verbatim: string1) }
    let!(:s3) { FactoryBot.create(:valid_source_verbatim, verbatim: 'This is a roof string.') }
    let!(:s2) { FactoryBot.create(:valid_source_verbatim, verbatim: string1) }
    let!(:s4) { FactoryBot.create(:valid_source_verbatim, verbatim: 'This is a r00f string.') }

    context 'fuzzy matching' do
      specify '#nearest_by_levenshtein(compared_string, column, limit) 1' do
        expect(s1.nearest_by_levenshtein(s1.verbatim, :cached).first).to eq(s2)
      end

      specify '#nearest_by_levenshtein 2' do
        expect(s2.nearest_by_levenshtein(s2.verbatim, :cached).first).to eq(s1)
      end

      specify '#nearest_by_levenshtein 3' do
        expect(s3.nearest_by_levenshtein(s3.verbatim, :cached).first).to eq(s4)
      end

      specify '#nearest_by_levenshtein 4' do
        expect(s4.nearest_by_levenshtein(s4.verbatim, :cached).first).to eq(s3)
      end

      context 'similar and identical' do

        # duplicate record
        let!(:s1a) do 
          s = s1.dup
          s.save!
          s
        end

        specify '#identical full matching' do
          expect(s1.identical.ids).to contain_exactly(s1a.id, s2.id)
        end

        specify '#similar full matching' do
          expect(s1.similar.ids).to contain_exactly(s1a.id, s2.id)
        end

        specify '.identical full matching ' do
          expect(Source.identical(s1.attributes).ids).to contain_exactly(s1.id, s1a.id, s2.id)
        end

        specify '.similar full matching' do
          expect(Source.similar(s1.attributes).ids).to contain_exactly(s1a.id, s2.id, s1.id)
        end
      end
    end
  end

  context 'duplicate record tests' do
=begin
    Species File conventions to remember:
      Two references are considered a match even if access code or the editor, OSF copy, or citation flags are different.
      Two references are considered different if they have different verbatim reference fields
        (including different capitalization), even if everything else matches!
      A reference is considered different if author, pub or containing ref aren't identical
      A reference is considered similar if years, title, volume or pages are either the same or missing.
      a similar reference may be added to the db by user request
      the values of verbatim data are ignored when checking if references are similar.
=end
    # xspecify 'find an identical record'
    # xspecify 'find a similar record'
  end

  context 'validate' do
    let!(:person1) { Person.create!(last_name: 'Smith', first_name: 'Jones') }
    let(:valid_attributes) { 
      {year: 1999,
       year_suffix: 'a',
       authors: [person1],
       bibtex_type: 'article'}
    }

    let!(:source1) { Source::Bibtex.create!(valid_attributes) } 
    let!(:source2) { Source::Bibtex.new( valid_attributes) } 

    specify '#year_suffix different suffix 1' do
      expect(source2.valid?).to be_falsey 
    end

    specify '#year_suffix different suffix 2' do
      source2.update(year_suffix: 'b')
      expect(source2.valid?).to be_truthy
    end

    specify '#year_suffix different authors 1' do
      source1.author_roles.create(person: FactoryBot.create(:valid_person))
      expect(source2.valid?).to be_truthy
    end

    specify '#year_suffix different authors 2' do
      source2.author_roles.build(person: FactoryBot.create(:valid_person))
      source2.update(year_suffix: 'c')
      expect(source2.valid?).to be_truthy
    end

    specify '#year_suffix different years 1' do
      source2.update(year: 2000) 
      expect(source2.valid?).to be_truthy
    end

    specify '#year_suffix validation disabled' do
      source2.no_year_suffix_validation = true
      expect(source2.valid?).to be_truthy
    end
  end

  specify '#verbatim_contents is not trimmed' do
    s = " asdf sd  \n  asdfd \r\n" 
    source.verbatim_contents = s
    source.valid?
    expect(source.verbatim_contents).to eq(s)
  end

  context 'concerns' do
    it_behaves_like 'alternate_values'
    it_behaves_like 'data_attributes'
    it_behaves_like 'has_roles'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
    it_behaves_like 'documentation'
  end

end
