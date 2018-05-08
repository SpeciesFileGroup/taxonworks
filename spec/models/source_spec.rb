require 'rails_helper'

describe Source, type: :model, group: :sources do
  let(:source) { Source.new }
  let(:string1) {'This is a base string.'}
  let!(:s1) { FactoryBot.create(:valid_source_verbatim, verbatim: string1) }
  let(:s1a) {
    s = s1.dup
    s.save!
    s
  }
  let(:s1b) { FactoryBot.create(:valid_source_verbatim,
                                verbatim: string1,
                                year: 2001,
                                month: 9,
                                day: 11) }
  let!(:s3) { FactoryBot.create(:valid_source_verbatim, verbatim: 'This is a roof string.') }
  let!(:s2) { FactoryBot.create(:valid_source_verbatim, verbatim: string1) }
  let!(:s4) { FactoryBot.create(:valid_source_verbatim, verbatim: 'This is a r00f string.') }

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

  # needs VCR
  context '#new_from_citation' do
    let(:citation) { 'Yoder, M. J., A. A. Valerio, A. Polaszek, L. Masner, and N. F. Johnson. 2009. Revision of Scelio pulchripennis - group species (Hymenoptera, Platygastroidea, Platygastridae). ZooKeys 20:53-118.' }

    specify 'when citation is < 5 characters false is returned' do
      VCR.use_cassette('source_citation_abc') {
        expect(Source.new_from_citation(citation: 'ABC')).to eq(false)
      }
    end

    specify 'when citation is > than 5 characters but unresolvable a Source::Verbatim instance is returned' do
      VCR.use_cassette('source_citation_xyz') {
        expect(Source.new_from_citation(citation: 'ABCDE XYZ').class).to eq(Source::Verbatim)
      }
    end

    specify 'when citation is resolvable a Source::Bibtex instance is returned' do
      VCR.use_cassette('source_citation_polaszek') {
        s = Source.new_from_citation(citation: citation)
        expect(s.class).to eq(Source::Bibtex)
      }
    end
  end

  # needs VCR
  context '#new_from_doi' do
    let(:doi) { 'http://dx.doi.org/10.3897/zookeys.20.205' }

    specify 'when doi is not provide false' do
      expect(Source.new_from_doi()).to eq(false)
    end

    specify 'when non resolvable doi is provided false is returned ' do
      expect(Source.new_from_doi(doi: 'asdfasdf')).to eq(false)
    end

    specify 'when resolvable doi is provided a new instance of Source::Bibtex is returned ' do
      expect(Source.new_from_doi(doi: doi).class).to eq(Source::Bibtex)
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
  end

  context 'matching' do
    context 'instance methods' do
      context '#identical' do
        xspecify 'full matching' do
          # duplicate record
          [s1, s1a, s1b]
          expect(s1.identical.ids).to contain_exactly(s1a.id)
        end

        xspecify 'full match test life years' do
          # life year mismatch
          [person1, person1a, person1b]
          expect(person1.identical.ids).to contain_exactly(person1a.id)
        end

        xspecify 'full match test active years' do
          # active year mismatch
          [person1, person1a, person1b]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.save!
          expect(person1.identical.count).to eq(0)
        end

        xspecify 'full match test active years only' do
          # life year mismatch, active year match
          [person1, person1a, person1b]
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(person1.identical.count).to eq(0)
        end

        xspecify 'full match all years' do
          # role count mismatch with no taxon name authorship
          [person1, person1a, person1b]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(person1.identical.ids).to contain_exactly(person1b.id)
        end
      end

      context '#similar' do
        xspecify 'full matching' do
          # duplicate record
          [person1, person1a, person1b, person2, person3, person4]
          expect(person1.similar.ids).to contain_exactly(person1a.id, person1b.id)
        end

        xspecify 'full match test life years' do
          # life year mismatch
          [person1, person1a, person1b, person2, person3, person4]
          expect(person1.similar.ids).to contain_exactly(person1a.id, person1b.id)
        end

        xspecify 'full match test active years' do
          # active year mismatch
          [person1, person1a, person1b, person2, person3, person4]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.save!
          expect(person1.similar.ids).to contain_exactly(person1b.id)
        end

        xspecify 'full match test active years only' do
          # life year mismatch, active year match
          [person1, person1a, person1b, person2, person3, person4]
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(person1.similar.ids).to contain_exactly(person1b.id)
        end

        xspecify 'full match all years' do
          # role count mismatch with no taxon name authorship
          [person1, person1a, person1b, person2, person3, person4]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(person1.similar.ids).to contain_exactly(person1b.id)
        end

        xspecify 'initials only' do
          [person1, person1a, person1b, person2, person3, person4]
          person1.first_name = 'J.'
          person1.save!
          test_person = Person.new(first_name: 'J.')
          expect(test_person.similar.ids).to contain_exactly(person2.id, person1.id)
        end
      end
    end

    context 'class methods' do
      context '#identical' do
        xspecify 'full matching' do
          # duplicate record
          [person1, person1a, person1b]
          expect(Person.identical(person1.attributes).ids).to contain_exactly(person1.id, person1a.id)
        end

        xspecify 'full match test life years' do
          # life year mismatch
          [person1, person1a, person1b]
          expect(Person.identical(person1.attributes).ids).to contain_exactly(person1a.id, person1.id)
        end

        xspecify 'full match test active years' do
          # active year mismatch
          [person1, person1a, person1b]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.save!
          expect(Person.identical(person1.attributes).ids).to contain_exactly(person1.id)
        end

        xspecify 'full match test active years only' do
          # life year mismatch, active year match
          [person1, person1a, person1b]
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(Person.identical(person1.attributes).ids).to contain_exactly(person1.id)
        end

        xspecify 'full match all years' do
          # role count mismatch with no taxon name authorship
          [person1, person1a, person1b]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(Person.identical(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
        end

        xspecify 'initials only' do
          [person1, person1a, person1b, person2, person3, person4]
          person1.first_name = 'J.'
          person1.save!
          test_person = Person.new(first_name: 'J.')
          expect(Person.identical(test_person.attributes)).to be_empty
        end
      end

      context '#similar' do
        xspecify 'full matching' do
          # duplicate record
          [person1, person1a, person1b, person2, person3, person4]
          expect(Person.similar(person1.attributes).ids).to contain_exactly(person1a.id, person1b.id, person1.id)
        end

        xspecify 'full match test life years' do
          # life year mismatch
          [person1, person1a, person1b, person2, person3, person4]
          expect(Person.similar(person1.attributes).ids).to contain_exactly(person1a.id, person1b.id, person1.id)
        end

        xspecify 'full match test active years' do
          # active year mismatch
          [person1, person1a, person1b, person2, person3, person4]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.save!
          expect(Person.similar(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
        end

        xspecify 'full match test active years only' do
          # life year mismatch, active year match
          [person1, person1a, person1b, person2, person3, person4]
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(Person.similar(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
        end

        xspecify 'full match all years' do
          # role count mismatch with no taxon name authorship
          [person1, person1a, person1b, person2, person3, person4]
          person1.year_born = 2000
          person1.year_died = 2015
          person1.year_active_start = 2012
          person1.year_active_end = 2015
          person1.save!
          expect(Person.similar(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
        end

        xspecify 'initials only' do
          [person1, person1a, person1b, person2, person3, person4]
          person1.first_name = 'J.'
          person1.save!
          test_person = Person.new(first_name: 'J.')
          expect(Person.similar(test_person.attributes).ids).to contain_exactly(person2.id, person1.id)
        end
      end
    end
  end

  context 'duplicate record tests' do
=begin
    Species File conventions to remember:
      Two references are considered a match even if access code or th3 editor, OSF copy, or citation flags are different.
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
