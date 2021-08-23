require 'rails_helper'
require 'support/debug/taxon_names'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:taxon_name) { TaxonName.new }

  context 'using before :all' do

    before(:all) do
      @subspecies = FactoryBot.create(:iczn_subspecies)
      @species = @subspecies.ancestor_at_rank('species')
      @subgenus = @subspecies.ancestor_at_rank('subgenus')
      @genus = @subspecies.ancestor_at_rank('genus')
      @tribe = @subspecies.ancestor_at_rank('tribe')
      @family = @subspecies.ancestor_at_rank('family')
      @root = @subspecies.root
    end

    after(:all) do
      TaxonNameRelationship.delete_all
      TaxonName.delete_all

      Citation.delete_all
      Source.destroy_all
      TaxonNameHierarchy.delete_all
    end

    specify '#name without space' do
      taxon_name.name = 'with space'
      taxon_name.valid?
      expect(taxon_name.errors[:name]).to_not be_empty
    end

    context '#year_of_publication' do
      specify 'format 1' do
        taxon_name.year_of_publication = 123
        taxon_name.valid?
        expect(taxon_name.errors[:year_of_publication]).to_not be_empty
      end

      specify 'format 2' do
        taxon_name.year_of_publication = '123'
        taxon_name.valid?
        expect(taxon_name.errors[:year_of_publication]).to_not be_empty
      end

      specify 'format 3' do
        taxon_name.year_of_publication = nil
        taxon_name.valid?
        expect(taxon_name.errors[:year_of_publication]).to be_empty
      end

      specify 'format 4' do
        taxon_name.year_of_publication = 1920
        taxon_name.valid?
        expect(taxon_name.errors[:year_of_publication]).to be_empty
      end

      specify 'format 4' do
        taxon_name.year_of_publication = 2999
        taxon_name.valid?
        expect(taxon_name.errors[:year_of_publication]).to_not be_empty
      end
    end


    # TODO: this all needs to go
    context 'lint checking FactoryBot' do
      specify 'is building all related names for respective models' do
        expect(@subspecies.ancestors.length).to be >= 10
        (@subspecies.ancestors + [@subspecies]).each do |i|
          if i.name != 'Root'
            expect(i.valid?).to be_truthy, "#{i.name} is not valid [#{i.errors.messages}], and is expected to be so- was your test db reset properly?"
          end
        end
      end

      specify 'ICN' do
        variety = FactoryBot.create(:icn_variety)
        expect(variety.ancestors.length).to be >= 17
        (variety.ancestors + [variety]).each do |i|
          if i.name != 'Root'
            expect(i.valid?).to be_truthy, "#{i.name} is not valid [#{i.errors.messages}], and is expected to be so- was your test db reset properly?"
          end
        end

        expect(variety.root.id).to eq(@species.root.id)
        expect(variety.cached_author_year).to eq('McAtee')
        expect(variety.cached_html).to eq('<i>Aus</i> (<i>Aus</i>) <i>aaa bbb</i> var. <i>ccc</i>')

        basionym = FactoryBot.create(:icn_variety, name: 'basionym', parent_id: variety.ancestor_at_rank('species').id,  verbatim_author: 'Linnaeus') # source_id: nil,
        r = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: basionym, object_taxon_name: variety, type: 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Basionym')
        variety.reload
        expect(variety.save).to be_truthy
        expect(variety.cached_author_year).to eq('(Linnaeus) McAtee')
      end

      xspecify 'ICN author' do # TODO: Re-enable this after discussion with @mjy @proceps
        t = FactoryBot.create(:icn_kingdom, verbatim_author: '(Seub.) Lowden')
        expect(t.original_author_year).to eq('(Seub.) Lowden')
      end
    end

    specify '#descendants_of' do
      expect(TaxonName.descendants_of(@genus).to_a).to contain_exactly(@subgenus, @species, @subspecies)
    end

    context '#ancestors_and_descendants_of' do
      specify 'returns an unordered list' do
        expect(TaxonName.ancestors_and_descendants_of(@genus).to_a.map(&:name)).to contain_exactly(
          'Animalia', 'Arthropoda', 'Cicadellidae', 'Erythroneura', 'Erythroneura', 'Erythroneurina',
          'Erythroneurini', 'Hemiptera', 'Insecta', 'Root', 'Typhlocybinae', 'vitata', 'vitis'
        )
      end
    end

    context 'hierarchy' do
      context 'rank related' do
        context '#ancestor_at_rank' do
          specify 'returns an ancestor at given rank' do
            expect(@genus.ancestor_at_rank('family').name).to eq('Cicadellidae')
          end

          specify "returns nil when given rank and name's rank are the same" do
            expect(@genus.ancestor_at_rank('genus')).to be_nil
          end

          specify "returns nil when given rank is lower than name's rank" do
            expect(@genus.ancestor_at_rank('species')).to be_nil
          end

          specify 'returns nil when given rank is not present in the parent chain' do
            expect(@genus.ancestor_at_rank('epifamily')).to be_nil
          end
        end
      end
    end

    context 'validation' do
      before { taxon_name.valid? }

      specify 'type is required, do not instantiate TaxonName' do
        expect(taxon_name.errors.include?(:type)).to be_truthy
      end

      context 'source' do
        specify 'when provided, is type Source::Bibtex' do
          h  = FactoryBot.build(:source_human)
          taxon_name.source = h
          taxon_name.valid?
          expect(taxon_name.errors.include?(:base)).to be_truthy
          b = FactoryBot.build(:source_bibtex)
          taxon_name.source = b
          taxon_name.valid?

          expect(taxon_name.errors.include?(:base)).to be_falsey # was source_id
        end
      end

      context 'name' do
        context 'validate cached values' do
          specify 'ICZN #cached_author_year' do
            expect(@subspecies.reload.cached_author_year).to eq('McAtee, 1900')
          end

          specify 'ICZN #cached_html' do
            expect(@subspecies.cached_html).to eq('<i>Erythroneura</i> (<i>Erythroneura</i>) <i>vitis vitata</i>')
          end

          specify 'ICZN species misspelling' do
            sp  = FactoryBot.create(:iczn_species, verbatim_author: 'Smith', year_of_publication: 2000, parent: @genus)
            sp.iczn_set_as_misapplication_of = @species
            expect(sp.save).to be_truthy
            expect(sp.cached_author_year).to eq('Smith, 2000 non McAtee, 1830')
          end

          specify 'ICZN combination' do
            g1 = FactoryBot.create(:relationship_genus, parent: @family, name: 'Aus')
            s = FactoryBot.create(:relationship_species, parent: g1, name: 'aus', year_of_publication: 1900, verbatim_author: 'McAtee')
            s.save! # WHY!?
            c1 = Combination.create!(genus: g1, species: s)
            expect(c1.cached_author_year).to eq('McAtee, 1900')
          end

          specify 'ICZN combination different genus' do
            g1 = FactoryBot.create(:relationship_genus, parent: @family, name: 'Aus')
            g2 = FactoryBot.create(:relationship_genus, parent: @family, name: 'Bus')
            s = FactoryBot.create(:relationship_species, parent: g1, name: 'aus', year_of_publication: 1900, verbatim_author: 'McAtee')
            s.original_genus = g2
            s.save!
            s.reload
            c1 = Combination.create!(genus: g1, species: s)
            expect(c1.cached_author_year).to eq('(McAtee, 1900)')
          end

          context 'ICZN family (behaviour for names above genus group)' do

            specify 'cached_author_year' do
              expect(@family.cached_author_year).to eq('Say, 1800')
            end

            specify 'cached_author_year with parentheses' do
              sp = FactoryBot.create(:relationship_species, parent: @genus, year_of_publication: 2000, verbatim_author: '(Dmitriev)')
              expect(sp.cached_author_year).to eq('(Dmitriev, 2000)')
            end

            specify 'original combination' do
              sp = FactoryBot.create(:relationship_species, name: 'albonigra', verbatim_name: 'albo-nigra', parent: @genus)
              sp.update(original_genus: @genus)
              expect(sp.cached_html).to eq('<i>Erythroneura albonigra</i>')
            end
          end

          specify 'nil author and year - cached value should be empty' do
            t = @subspecies.ancestor_at_rank('kingdom')
            expect(t.cached_author_year).to eq(nil)
          end

          specify 'author with parentheses' do
            c = FactoryBot.build(:relationship_species, parent: nil, verbatim_author: '(Dmitriev)', year_of_publication: 2000)
            expect(c.get_author_and_year).to eq('(Dmitriev, 2000)')
          end

          specify 'author without parentheses' do
            c = FactoryBot.build(:relationship_species, parent: nil, verbatim_author: 'Dmitriev', year_of_publication: 2000)
            expect(c.get_author_and_year).to eq('Dmitriev, 2000')
          end

          specify 'no original combination relationships' do
            ssp = FactoryBot.build(:iczn_subspecies, parent: @species)
            expect(ssp.get_genus_species(:original, :self).nil?).to be_truthy
            expect(ssp.get_genus_species(:original, :alternative).nil?).to be_truthy
            #            expect(ssp.get_genus_species(:current, :self).nil?).to be_falsey
            #            expect(ssp.get_genus_species(:current, :alternative).nil?).to be_falsey
            ssp.save
            # expect(ssp.cached_original_combination.nil?).to be_truthy
            expect(ssp.cached_primary_homonym.nil?).to be_truthy
            expect(ssp.cached_primary_homonym_alternative_spelling.nil?).to be_truthy
            expect(ssp.cached_secondary_homonym).to eq('Erythroneura vitata')
            expect(ssp.cached_secondary_homonym_alternative_spelling).to eq('Erythroneura uitata')
          end

          specify 'misspelled original combination' do
            g = FactoryBot.create(:relationship_genus, name: 'Errorneura')

            g.iczn_set_as_misspelling_of = @genus
            expect(g.save).to be_truthy

            @subspecies.original_genus = g # ! not saved originally !!
            @subspecies.reload

            expect(g.reload.get_full_name_html).to eq('<i>Errorneura</i> [sic]')

            expect(@subspecies.get_original_combination).to eq('Errorneura [sic] [SPECIES NOT SPECIFIED] vitata')
            expect(@subspecies.get_original_combination_html).to eq('<i>Errorneura</i> [sic] [SPECIES NOT SPECIFIED] <i>vitata</i>')
            expect(@subspecies.get_author_and_year).to eq ('McAtee, 1900')
          end

          # What code is this supposed to catch?
          specify 'moving nominotypical taxon' do
            sp = FactoryBot.create(:iczn_species, name: 'aaa', parent: @genus)
            subsp = FactoryBot.create(:iczn_subspecies, name: 'aaa', parent: sp)
            subsp.parent = @species
            subsp.valid?
            expect(subsp.errors.include?(:parent_id)).to be_truthy
          end

          context 'cached homonyms' do
            before(:each) do
              @g1 = FactoryBot.create(:relationship_genus, name: 'Aus', parent: @tribe, year_of_publication: 1999)
              @g2 = FactoryBot.create(:relationship_genus, name: 'Bus', parent: @tribe, year_of_publication: 2000)
              @s1 = FactoryBot.create(:relationship_species, name: 'vitatus', parent: @g1, year_of_publication: 1999)
              @s2 = FactoryBot.create(:relationship_species, name: 'vitatta', parent: @g2, year_of_publication: 2000)
              expect(@family.valid?).to be_truthy
              expect(@tribe.valid?).to be_truthy
              expect(@g1.valid?).to be_truthy
              expect(@g2.valid?).to be_truthy
              expect(@s1.valid?).to be_truthy
              expect(@s2.valid?).to be_truthy
            end

            specify 'primary homonym' do
              expect(@family.cached_primary_homonym).to eq('Cicadellidae')
              expect(@tribe.cached_primary_homonym).to eq('Erythroneurini')
              expect(@tribe.cached_primary_homonym_alternative_spelling).to eq('Erythroneuridae')
              expect(@g1.cached_primary_homonym).to eq('Aus')
              expect(@g2.cached_primary_homonym).to eq('Bus')
              expect(@s1.cached_primary_homonym.blank?).to be_truthy
              expect(@s2.cached_primary_homonym.blank?).to be_truthy
            end

            specify 'secondary homonym' do
              expect(@family.cached_secondary_homonym.blank?).to be_truthy
              expect(@g1.cached_secondary_homonym.blank?).to be_truthy
              expect(@g2.cached_secondary_homonym.blank?).to be_truthy
              expect(@s1.save).to be_truthy
              expect(@s1.cached_secondary_homonym).to eq('Aus vitatus')
              expect(@s2.save).to be_truthy
              expect(@s2.cached_secondary_homonym).to eq('Bus vitatta')
            end

            specify 'original genus' do
              @s1.original_genus = @g1
              @s2.original_genus = @g1
              expect(@s1.save).to be_truthy
              expect(@s2.save).to be_truthy
              @s1.reload
              @s2.reload
              expect(@s1.cached_primary_homonym).to eq('Aus vitatus')
              expect(@s2.cached_primary_homonym).to eq('Aus vitatta')
              @s1.save
              expect(@s1.cached_secondary_homonym).to eq('Aus vitatus')
              @s2.save
              expect(@s2.cached_secondary_homonym).to eq('Bus vitatta')
              expect(@s1.cached_primary_homonym_alternative_spelling).to eq('Aus uitata')
              expect(@s2.cached_primary_homonym_alternative_spelling).to eq('Aus uitata')
              expect(@s1.cached_secondary_homonym_alternative_spelling).to eq('Aus uitata')
              expect(@s2.cached_secondary_homonym_alternative_spelling).to eq('Bus uitata')
            end
          end

          context 'mismatching cached values' do
            before(:all) do
              @g = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @family)
              @s = FactoryBot.build(:relationship_species, name: 'dus', parent: @g)
            end

            specify 'missing cached values' do
              @s.save
              @s.update_column(:cached_original_combination, 'aaa')
              @s.soft_validate(only_sets: :cached_names)
              expect(@s.soft_validations.messages_on(:base).count).to eq(1)
              @s.fix_soft_validations
              @s.soft_validate(only_sets: :cached_names)
              expect(@s.soft_validations.messages_on(:base).empty?).to be_truthy
            end
          end

          context 'valid_taxon_name' do
            context 'validity with/out classifications' do
              let!(:valid_genus) { Protonym.create(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: @family) }
              let!(:other_genus) { Protonym.create(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: @family) }

              before {
                TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: valid_genus, object_taxon_name: other_genus)
              }

              context 'without valid classification' do
                specify '#relationship_invalid?' do
                  expect(valid_genus.relationship_invalid?).to be_truthy
                end

                specify '#classification_invalid_or_unavailable?' do
                  expect(valid_genus.classification_invalid_or_unavailable?).to be_falsey
                end

                specify '#classification_valid?' do
                  expect(valid_genus.classification_valid?).to be_falsey
                end

                specify '#unavailable_or_invalid?' do
                  expect(valid_genus.unavailable_or_invalid?).to be_truthy
                end

                # ONLY #reload when you expect after_save to be examined (in our case cached value checks)
                context 'values set after_save' do
                  before {
                    valid_genus.reload
                    other_genus.reload
                  }

                  specify '#is_valid?' do
                    expect(valid_genus.is_valid?).to be_falsey
                  end

                  specify 'valid name is other' do
                    expect(valid_genus.valid_taxon_name).to eq(other_genus)
                  end
                end
              end

              context 'with valid classification' do
                before {
                  TaxonNameClassification::Iczn::Available::Valid.create!(taxon_name: valid_genus)
                }

                specify '#relationship_invalid?' do
                  expect(valid_genus.relationship_invalid?).to be_truthy
                end

                specify '#classification_invalid_or_unavailable?' do
                  expect(valid_genus.classification_invalid_or_unavailable?).to be_falsey
                end

                specify '#classification_valid?' do
                  expect(valid_genus.classification_valid?).to be_truthy
                end

                specify '#unavailable_or_invalid?' do
                  expect(valid_genus.unavailable_or_invalid?).to be_falsey
                end

                context 'values set after_save' do
                  before {
                    valid_genus.reload
                    other_genus.reload
                  }

                  specify '#is_valid?' do
                    expect(valid_genus.is_valid?).to be_truthy
                  end

                  specify 'valid name is self' do
                    expect(valid_genus.valid_taxon_name).to eq(valid_genus)
                  end
                end
              end
            end

            specify 'get_valid_taxon_name' do
              g1 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @family)
              g2 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @family)
              g3 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @family)
              g4 = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @family)
              s1 = FactoryBot.create(:valid_source_bibtex, title: 'article 1', year: 1900)
              s2 = FactoryBot.create(:valid_source_bibtex, title: 'article 2', year: 2000)
              expect(g1.get_valid_taxon_name).to eq(g1)
              r1 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: g1, object_taxon_name: g2, source: s1)
              r1.reload
              g1.save
              g1.reload
              expect(g1.get_valid_taxon_name).to eq(g2)
              r2 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: g2, object_taxon_name: g3, source: s1)
              r2.reload
              g2.save
              g2.reload
              g1.save
              g1.reload
              expect(g1.get_valid_taxon_name).to eq(g3)
              r3 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: g2, object_taxon_name: g4, source: s2)
              r3.reload
              g2.save
              g2.reload
              g1.save
              g1.reload
              expect(g1.get_valid_taxon_name).to eq(g4)
              expect(g4.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([g1, g2])
            end

            specify 'list of invalid taxon names, year priority' do
              a   = FactoryBot.create(:relationship_genus, name: 'Aus', parent: @family)
              b   = FactoryBot.create(:relationship_genus, name: 'Bus', parent: @family)
              c   = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @family)
              d   = FactoryBot.create(:relationship_genus, name: 'Dus', parent: @family)
              e   = FactoryBot.create(:relationship_genus, name: 'Eus', parent: @family)
              f   = FactoryBot.create(:relationship_genus, name: 'Fus', parent: @family)
              g   = FactoryBot.create(:relationship_genus, name: 'Gus', parent: @family)
              h   = FactoryBot.create(:relationship_genus, name: 'Hus', parent: @family)
              i   = FactoryBot.create(:relationship_genus, name: 'Ius', parent: @family)
              s1  = FactoryBot.create(:valid_source_bibtex, title: 'article 1', year: 1900)
              s2  = FactoryBot.create(:valid_source_bibtex, title: 'article 2', year: 1950)
              s3  = FactoryBot.create(:valid_source_bibtex, title: 'article 3', year: 1960)
              s4  = FactoryBot.create(:valid_source_bibtex, title: 'article 4', year: 2000)
              s5  = FactoryBot.create(:valid_source_bibtex, title: 'article 5', year: 2010)
              r1  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: d, object_taxon_name: a, source: s1)
              r2  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: d, object_taxon_name: b, source: s1)
              r3  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: d, object_taxon_name: c, source: s5)
              r4  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: e, object_taxon_name: b, source: s1)
              r5  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: e, object_taxon_name: c, source: s4)
              r6  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: e, object_taxon_name: f, source: s2)
              r7  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: f, object_taxon_name: e, source: s3)
              r8  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: g, object_taxon_name: d, source: s4)
              r9  = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: h, object_taxon_name: e)
              r10 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: i, object_taxon_name: e, source: s2)
              r11 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: i, object_taxon_name: f, source: s3)
              expect(a.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([])
              expect(b.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([])
              expect(c.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([d, e, f, g, h, i])
              expect(d.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([g])
              expect(e.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([f, h, i])
              expect(f.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([i])
              expect(g.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([])
              expect(h.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([])
              expect(i.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([])
              expect(a.get_valid_taxon_name).to eq(a)
              expect(b.get_valid_taxon_name).to eq(b)
              expect(c.get_valid_taxon_name).to eq(c)
              expect(d.get_valid_taxon_name).to eq(c)
              expect(e.get_valid_taxon_name).to eq(c)
              expect(f.get_valid_taxon_name).to eq(c)
              expect(g.get_valid_taxon_name).to eq(c)
              expect(h.get_valid_taxon_name).to eq(c)
              expect(i.get_valid_taxon_name).to eq(c)
            end

            context 'invalid taxon_names with reverse relationship' do
              let!(:a)  { FactoryBot.create(:relationship_genus, name: 'Aus', parent: @family) }
              let!(:b)  { FactoryBot.create(:relationship_genus, name: 'Bus', parent: @family) }
              let!(:s)  { TaxonNameClassification::Iczn::Available::Valid.create(taxon_name: a) }
              let!(:r1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: a, object_taxon_name: b) }
              let!(:r2) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: b, object_taxon_name: a) }

              specify 'for subject' do
                expect(a.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([b])
                expect(a.get_valid_taxon_name).to eq(a)
              end

              specify 'for object' do
                expect(b.list_of_invalid_taxon_names.sort_by { |n| n.id }).to eq([])
                expect(b.get_valid_taxon_name).to eq(a)
              end
            end

          end
        end
      end

      context 'relationships' do
        specify 'invalid parent' do
          g  = FactoryBot.create(:iczn_genus, parent: @family)
          s  = FactoryBot.create(:iczn_species, parent: g)

          r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: @genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
          c1 = FactoryBot.create(:taxon_name_classification, taxon_name: g, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
          s.soft_validate(only_sets: :parent_is_valid_name)
          g.soft_validate(only_sets: :parent_is_valid_name)
          expect(s.soft_validations.messages_on(:parent_id).count).to eq(1)

          # !!
          expect(g.soft_validations.messages_on(:base).count).to eq(1)

          s.fix_soft_validations
          s.soft_validate(only_sets: :parent_is_valid_name)
          expect(s.soft_validations.messages_on(:parent_id).empty?).to be_truthy
        end

        specify 'conflicting synonyms: reverse relationships' do
          a  = FactoryBot.create(:relationship_genus, name: 'Aus', parent: @family)
          b  = FactoryBot.create(:relationship_genus, name: 'Bus', parent: @family)
          r1 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: a, object_taxon_name: b)
          r2 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: b, object_taxon_name: a)
          a.soft_validate(only_sets: :not_synonym_of_self)
          expect(a.soft_validations.messages_on(:base).count).to eq(1)
          s = TaxonNameClassification::Iczn::Available::Valid.create(taxon_name: a)
          a.soft_validate(only_sets: :not_synonym_of_self)
          expect(a.soft_validations.messages_on(:base).count).to eq(0)
        end

        specify 'conflicting synonyms: same nomenclatural priority' do
          a  = FactoryBot.create(:relationship_genus, name: 'Aus', parent: @family)
          b  = FactoryBot.create(:relationship_genus, name: 'Bus', parent: @family)
          c  = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @family)
          s1 = FactoryBot.create(:valid_source_bibtex, title: 'article 1', year: 1900)

          r1 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: a, object_taxon_name: b)
          r2 = TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: a, object_taxon_name: c)

          a.soft_validate(only_sets: :two_unresolved_alternative_synonyms)
          expect(a.soft_validations.messages_on(:base).count).to eq(1)
          r1.source = s1
          r1.save

          a.reload
          a.soft_validate(only_sets: :two_unresolved_alternative_synonyms)
          expect(a.soft_validations.messages_on(:base).count).to eq(0)
        end
      end
    end

  end # END before(:all) spinups


  # DO NOT USE before(:all) OR any factory that creates the full hierarchy here
  context 'a clean slate' do

    # A Hierarchy
    let(:root1) { FactoryBot.create(:root_taxon_name) }
    let(:klass) { Protonym.create!(name: 'Insecta', rank_class: Ranks.lookup(:iczn, :class), parent: root1) }
    let(:order) { Protonym.create!(name: 'Hemiptera', rank_class: Ranks.lookup(:iczn, :order), parent: klass) }
    let(:family) { Protonym.create!(name: 'Cicadellidae', rank_class: Ranks.lookup(:iczn, :family), parent: order) }
    let(:subfamily) { Protonym.create!(name: 'Typhlocybinae', rank_class: Ranks.lookup(:iczn, :subfamily), parent: family) }
    let(:tribe) { Protonym.create!(name: 'Erythroneurini', rank_class: Ranks.lookup(:iczn, :tribe), parent: subfamily) }
    let(:genus) { Protonym.create!(name: 'Erythroneura', rank_class: Ranks.lookup(:iczn, :genus), parent: tribe) }
    let(:subgenus) { Protonym.create!(name: 'Erythroneura', rank_class: Ranks.lookup(:iczn, :subgenus), parent: genus) }
    let(:species) { Protonym.create!(name: 'vitis', rank_class: Ranks.lookup(:iczn, :species), parent: subgenus) }

    # "Free" names, linked only to root
    let(:other_species) { Protonym.create!(name: 'afafa', rank_class: Ranks.lookup(:iczn, :species), parent: root1) }

    context 'with a heirarchy created' do
      before {species} # create the full hierarchy

      context 'recent use' do
        let!(:tc1) { TaxonNameClassification::Iczn::Available::Invalid.create!(taxon_name: species) }
        let!(:tr1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: genus, object_taxon_name: subgenus ) }

        # This isn't recent!
        let!(:tr2) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
          subject_taxon_name: tribe,
          object_taxon_name: subfamily,
          created_at: 1.month.ago,
          updated_at: 1.month.ago ) }

        let(:user_id) { species.created_by_id }
        let(:project_id) { species.project_id }

        specify '.used_recently' do
          expect(TaxonName.used_recently(user_id, project_id).count).to eq(6)
        end

        # everything is recent
        specify '.used_recently_in_classifications' do
          expect(TaxonName.used_recently_in_classifications(user_id, project_id).map(&:id)).to contain_exactly(species.id)
        end

        specify '.used_recently_in_relationships' do
          expect(TaxonName.used_recently_in_relationships(user_id, project_id).map(&:id)).to contain_exactly(subgenus.id, genus.id)
        end

        specify '.select_optimized' do
          expect(TaxonName.select_optimized(user_id, project_id)).to be_truthy
        end
      end

      context 'scopes' do
        context '.ancestors_and_descendants_of' do
          specify 'includes leaves to root, and target node' do
            expect(TaxonName.ancestors_and_descendants_of(genus).all.map(&:name)).to contain_exactly(
              *%w{Root Insecta Hemiptera Cicadellidae Typhlocybinae Erythroneurini Erythroneura Erythroneura vitis}
            )
          end

          # result is not ordered
          specify 'can be chained' do
            expect(TaxonName.ancestors_and_descendants_of(genus).where("name ILIKE 'E%'").all.map(&:name)).to contain_exactly(
              *%w{Erythroneurini Erythroneura Erythroneura}
            )
          end
        end

        context '.ancestors_of' do
          specify 'does not return target' do
            expect(TaxonName.ancestors_of(subfamily).pluck(:name)).to eq(
              %w{Root Insecta Hemiptera Cicadellidae}
            )
          end
        end
      end
    end

    context 'instance methods' do

      specify '#genderized_name 1' do
        expect(genus.genderized_name).to eq('Erythroneura')
      end

      specify '#genderized_name 2' do
        expect(genus.genderized_name(:masculine)).to eq('Erythroneura')
      end

      context '#verbatim_author' do
        specify 'parens are allowed' do
          taxon_name.verbatim_author = '(Smith)'
          taxon_name.valid?
          expect(taxon_name.errors.include?(:verbatim_author)).to be_falsey
        end
      end

      context '#author_string' do
        specify 'verbatim_author absent; source with a single author' do
          source = FactoryBot.create(:src_dmitriev)
          taxon_name.source = source
          expect(taxon_name.year_integer).to eq(1940)
          expect(taxon_name.author_string).to eq('Dmitriev')
          source.destroy
        end

        specify 'verbatim_author absent; source with a multiple authors' do
          source = FactoryBot.create(:src_mult_authors)
          taxon_name.source = source
          expect(taxon_name.author_string).to eq('Thomas, Fowler & Hunt')
          source.destroy
        end

        specify 'verbatim_author present' do
          taxon_name.verbatim_author = 'Linnaeus'
          taxon_name.year_of_publication = 1999
          expect(taxon_name.year_integer).to eq(1999)
          expect(taxon_name.author_string).to eq('Linnaeus')
        end
      end

      context 'returning related combinations' do
        let(:c1) { FactoryBot.build(:combination, parent: root1) }
        let(:c2) { FactoryBot.build(:combination, parent: root1) }

        before do
          c1.genus = genus
          c2.genus = genus
          c2.subgenus = subgenus
          c1.save
          c2.save
        end

        specify '#combination_list_all' do
          expect(genus.combination_list_all).to include(c1, c2)
          expect(subgenus.combination_list_all).to eq([c2])
        end

        specify '#combination_list_self' do
          expect(genus.combination_list_self).to eq([c1])
          expect(subgenus.combination_list_self).to eq([c2])
        end
      end

      context '#rank_class' do
        specify 'returns the passed value when not yet validated and not a NomenclaturalRank' do
          taxon_name.rank_class = 'foo'
          expect(taxon_name.rank_class).to eq('foo')
        end

        specify 'returns a NomenclaturalRank when available' do
          taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
          expect(taxon_name.rank_class).to eq(NomenclaturalRank::Iczn::HigherClassificationGroup::Order)
          taxon_name.rank_class = Ranks.lookup(:icn, 'family')
          expect(taxon_name.rank_class).to eq(NomenclaturalRank::Icn::FamilyGroup::Family)
        end
      end

      context '#rank' do
        specify 'returns nil when not a NomenclaturalRank (i.e. invalidly_published)' do
          taxon_name.rank_class = 'foo'
          expect(taxon_name.rank).to be_nil
        end

        context 'returns vernacular when rank_class is a NomenclaturalRank (i.e. validly_published)' do
          specify 'for :iczn' do
            taxon_name.rank_class = Ranks.lookup(:iczn, 'order')
            expect(taxon_name.rank).to eq('order')
          end

          specify 'for :icn' do
            taxon_name.rank_class = Ranks.lookup(:icn, 'family')
            expect(taxon_name.rank).to eq('family')
          end
        end
      end

      context '#nomenclature_date' do
        let(:f1) { FactoryBot.create(:relationship_family, year_of_publication: 1900) }
        let(:f2) { FactoryBot.create(:relationship_family, year_of_publication: 1950) }

        specify 'simple case' do
          expect(f2.nomenclature_date.year).to eq(1950)
        end

        specify 'family replacement before 1961' do
          r = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: f2, object_taxon_name: f1, type: 'TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961')
          expect(f2.nomenclature_date.year).to eq(1900)
        end
      end
    end

    context 'associations' do
      specify '#source (original)' do
        expect(taxon_name.source = Source.new).to be_truthy
      end

      specify '#valid_taxon_name' do
        expect(other_species.valid_taxon_name = Protonym.new).to be_truthy
      end

      specify '#taxon_name_relationships' do
        expect(taxon_name.taxon_name_relationships << TaxonNameRelationship.new).to be_truthy
      end

      context 'instance tests' do
        let(:type_of_genus) { Protonym.create(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root1) }
        let(:original_genus) { Protonym.create(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root1) }
        let!(:relationship1) { FactoryBot.create(:type_species_relationship, subject_taxon_name: species, object_taxon_name: type_of_genus) } #  @taxon_name
        let!(:relationship2) { TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(subject_taxon_name: original_genus, object_taxon_name: species) } #  @taxon_name

        # TaxonNameRelationships in which the taxon name is the subject
        specify '#taxon_name_relationships' do
          expect(species.taxon_name_relationships.map(&:type_name)).to contain_exactly(relationship1.type_name)
        end

        # TaxonNameRelationships in which the taxon name is the subject OR object
        specify '#all_taxon_name_relationships' do
          expect(species.all_taxon_name_relationships.map(&:type_name)).to contain_exactly(relationship1.type_name, relationship2.type_name)
        end

        # TaxonNames related by all_taxon_name_relationships
        specify '#related_taxon_names' do
          expect(species.related_taxon_names.sort).to eq([type_of_genus, original_genus].sort)
        end

        context '#unavilable_or_invalid' do
          let!(:relationship) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: original_genus, object_taxon_name: type_of_genus) }

          specify 'subject is invalid' do
            expect(original_genus.unavailable_or_invalid?).to be_truthy
          end

          specify 'object is valid' do
            expect(type_of_genus.unavailable_or_invalid?).to be_falsey
          end
        end
      end
    end

    context '#destroy' do
      context 'without children' do

        specify 'target is not a #leaf?' do
          expect(root1.leaf?).to be_truthy
        end

        specify 'record can be destroyed' do
          expect(root1.destroy).to be_truthy
        end
      end

      context 'with children' do
        let!(:child) { Protonym.create!(name: 'Destroyidae', parent: root1, rank_class: Ranks.lookup(:iczn, :family)) }

        before {
          root1.reload # child has been created in let!()
          root1.destroy
        }

        specify 'target is not a #leaf?' do
          expect(root1.leaf?).to be_falsey
        end

        specify 'record can not destroyed' do
          expect(root1.destroyed?).to be_falsey
        end

        specify 'errors are added to base' do
          expect(root1.errors[:base]).to be_truthy
        end
      end
    end

    context '#gbif_status_array' do
      let(:t1) { FactoryBot.create(:iczn_species, name: 'aus', parent: root1) }
      let(:t2) { FactoryBot.create(:iczn_species, name: 'bus', parent: root1) }
      let!(:r2) { FactoryBot.create(:taxon_name_relationship, subject_taxon_name: t2, object_taxon_name: t1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective') }

      specify 'valid species' do
        expect(t1.gbif_status_array).to eq(['valid'])
      end

      specify 'synonym' do
        expect(t2.gbif_status_array).to eq(['invalidum'])
      end

      specify 'nomen nudum' do
        c = FactoryBot.create(:taxon_name_classification, taxon_name: t2, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::ConditionallyProposedAfter1960')
        t2.reload
        expect(t2.gbif_status_array).to eq(['nudum'])
      end
    end

    context 'status string arrays' do
      let(:family) { Protonym.create!(name: 'Statusidae', rank_class: Ranks.lookup(:iczn, :family), parent: root1) }

      let!(:a) { FactoryBot.create(:relationship_genus, name: 'Aus', parent: family) }
      let!(:b) { FactoryBot.create(:relationship_genus, name: 'Bus', parent: family) }
      let!(:s) { TaxonNameClassification::Iczn::Unavailable.create(taxon_name: a) }
      let!(:r1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: a, object_taxon_name: b) }

      specify '#combined_statuses' do
        expect(a.combined_statuses).to eq(['synonym', 'unavailable'])
      end

      specify '#statuses_from_classifications' do
        expect(a.statuses_from_classifications).to eq(['unavailable'])
      end

      specify '#status_from_relationships' do
        expect(a.statuses_from_relationships).to eq(['synonym'])
      end
    end

    context 'methods from awesome_nested_set' do
      context 'root names' do

        let(:p) { Project.create(name: 'Taxon-name root test.', without_root_taxon_name: true) }
        let(:root2) { FactoryBot.build(:root_taxon_name) }

        specify 'a second root (parent is nul) in a given project is not allowed' do
          expect(root1.parent).to be_nil
          expect(root2.parent).to be_nil
          expect(root1.project_id).to eq(1)
          expect(root2.project_id).to eq(1)
          expect(root2.valid?).to be_falsey
          expect(root2.errors.include?(:parent_id)).to be_truthy
        end

        specify 'permit multiple roots in different projects' do
          root2.project_id = p.id
          expect(root2.parent).to be_nil
          expect(root2.valid?).to be_truthy
        end

        specify 'roots can be saved without raising 1' do
          root2.project_id = p.id
          expect(root2.save).to be_truthy
        end

        specify 'roots can be saved without raising 2' do
          expect(root1.save).to be_truthy
        end

        specify 'scope project_root' do
          root1
          expect(TaxonName.project_root(1).first).to eq(root1)
        end
      end

      # run through the awesome_nested_set methods: https://github.com/collectiveidea/awesome_nested_set/wiki/_pages
      context 'handle a simple hierarchy with awesome_nested_set' do
        let!(:new_root) { FactoryBot.create(:root_taxon_name, project: p) }
        let!(:family1) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'family'), name: 'Aidae', parent: new_root, project: p) }
        let!(:genus1) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'genus'), name: 'Aus', parent: family1, project: p) }
        let!(:genus2) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'genus'), name: 'Bus', parent: family1, project: p) }
        let!(:species1) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'species'), name: 'aus', parent: genus1, project: p) }
        let!(:species2) { Protonym.create!(rank_class: Ranks.lookup(:iczn, 'species'), name: 'bus', parent: genus2, project: p) }

        specify 'root' do
          expect(species1.root).to eq(new_root)
        end

        specify 'ancestors' do
          expect(new_root.ancestors.size).to eq(0)
          expect(family1.ancestors.size).to eq(1)
          expect(family1.ancestors).to eq([new_root])
          expect(species1.ancestors.size).to eq(3)
        end

        specify 'parent' do
          expect(new_root.parent).to eq(nil)
          expect(family1.parent).to eq(new_root)
        end

        specify 'leaves' do
          new_root.reload
          expect(new_root.leaves.to_a).to contain_exactly(species1, species2) # doesn't test order
        end

        context 'housekeeping with ancestors and descendants' do
          # xspecify 'updated_on is not touched for ancestors when a child moves' do
          #   g1_updated = genus1.updated_at
          #   g1_created = genus1.created_at
          #   g2_updated = genus2.updated_at
          #   g2_created = genus2.created_at
          #   species1.move_to_child_of(genus2)
          #   expect(genus1.updated_at).to eq(g1_updated)
          #   expect(genus1.created_at).to eq(g1_created)
          #   expect(genus2.updated_at).to eq(g2_updated)
          #   expect(genus2.created_at).to eq(g2_created)
          # end
        end
      end
    end

    context 'soft validation' do
      specify 'run all soft validations without error' do
        expect(taxon_name.soft_validate).to be_truthy
      end
    end
  end

  # Some observations:
  #  - reified ids are only for original combinations (for which we have no ID)
  #  - reified ids never reference gender changes because they are always in context of original combination, i.e. there is never a gender change
  context 'reified ids' do

    let(:root1) { FactoryBot.create(:root_taxon_name) }
    let(:family) { Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: root1) }
    let(:genus1) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let(:genus2) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let(:subgenus) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :subgenus), parent: genus2) }
    let(:species) { Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:iczn, :species), parent: genus1) }


    # Same as current classification
    let(:c1) { Combination.create!(genus: genus1, species: species) }

    # Different than current classification
    let(:c2) { Combination.create!(genus: genus2, species: species) }

    let(:c3) { Combination.create!(genus: genus1, subgenus: genus2, species: species) }


    specify '#reified_id 1' do
      expect(family.reified_id).to eq(family.to_param)
    end

    specify '#reified_id 2' do
      expect(species.reified_id).to eq(species.to_param)
    end

    specify '#reified_id 3' do
      species.update!(verbatim_author: 'Smith')
      expect(species.reified_id).to eq(species.id.to_param)
    end

    specify '#reified_id 4' do
      species.update!(verbatim_author: '(Smith)')
      expect(species.reified_id).to eq(species.to_param)
    end

    specify '#reified_id with original_combination relationship' do
      species.update!(verbatim_author: 'Smith', original_genus: genus2)
      a = [species.id, Digest::MD5.hexdigest(species.cached_original_combination)].join('-')
      expect(species.reified_id).to eq(a)
    end

    specify '#reified_id 1' do
      species.update!(parent: subgenus, original_genus: genus1)
      species.reload
      a = [species.id, Digest::MD5.hexdigest(species.cached_original_combination)].join('-')
      expect(species.reified_id).to eq(a)
    end
  end

  context 'combinations not in scope' do
    let!(:root1) { FactoryBot.create(:root_taxon_name) }
    let!(:family1) { Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: root1) }
    let!(:family2) { Protonym.create!(name: 'Bidae', rank_class: Ranks.lookup(:iczn, :family), parent: root1) }
    let!(:genus1) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: family1) }
    let!(:genus2) { Protonym.create!(name: 'Ogus', rank_class: Ranks.lookup(:iczn, :genus), parent: family2) }
    let!(:species1) { Protonym.create!(name: 'aus', rank_class: Ranks.lookup(:iczn, :species), parent: genus1) }
    let!(:species2) { Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: genus2) }

    let!(:c1) { Combination.create!(genus: genus1, species: species1) }
    let!(:c2) { Combination.create!(genus: genus2, species: species1) } # target!
    let!(:c3) { Combination.create!(genus: genus2, species: species2) } # out of scope red herring

    # TODO: Spec logger with debug:true
    #  before do
    #    Support::Debug::TaxonNames.puts_names(
    #      [root1, family1, family2, genus1, genus2, species1, species2, c1, c2]
    #    )
    #  end

    specify 'ensure combination is not in scope 1' do
      expect(genus1.descendants.to_a).to_not include(c1, c2, c3) 
    end

    specify 'ensure combination is not in scope 2' do
      expect(genus2.descendants.to_a).to_not include(c1, c2) 
    end

    specify '#out_of_scope_combinations 1' do
      expect(genus1.out_of_scope_combinations).to contain_exactly(c2)
    end

    specify '#out_of_scope_combinations 1' do
      expect(genus2.out_of_scope_combinations).to contain_exactly()
    end

    specify '.out_of_scope_combinations 1' do
      expect(TaxonName.out_of_scope_combinations(genus1.id)).to contain_exactly(c2)
    end

    specify '.out_of_scope_combinations 1' do
      expect(TaxonName.out_of_scope_combinations(genus2.id)).to contain_exactly()
    end

    specify '#out_of_scope_combinations 2' do
      expect(family1.out_of_scope_combinations).to contain_exactly(c2) # c1 is present because of parenthood
    end
  end

  context 'concerns' do
    it_behaves_like 'data_attributes'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'is_data'
  end
end
# rspec -t group:nomenclature
# rspec -t group:soft_validation
