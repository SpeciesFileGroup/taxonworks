require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  # TODO: cleanup don't leave dirty .... 
  before(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    TaxonNameHierarchy.delete_all
    @order = FactoryBot.create(:iczn_order)
  end

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    Citation.delete_all
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  end

  let(:protonym) { Protonym.new }
  let(:root) { Protonym.where(name: 'Root').first  }

  context 'validation' do
    before { protonym.valid? }

    context 'rank_class' do
      specify 'is valid when a NomenclaturalRank subclass' do
        protonym.rank_class = Ranks.lookup(:iczn, 'order')
        protonym.name = 'Aaa'
        protonym.valid?
        expect(protonym.errors.include?(:rank_class)).to be_falsey
      end

      specify 'is invalid when not a NomenclaturalRank subclass' do
        protonym.rank_class = 'foo'
        protonym.valid?
        expect(protonym.errors.include?(:rank_class)).to be_truthy
      end

      specify 'parent rank is higher' do
        protonym.update(rank_class: Ranks.lookup(:iczn, 'Genus'), name: 'Aus')
        protonym.parent = @species
        protonym.valid?
        expect(protonym.errors.include?(:parent_id)).to be_truthy
      end

      specify 'child rank is lower' do
        phylum = FactoryBot.create(:iczn_phylum)
        kingdom = phylum.ancestor_at_rank('kingdom')
        kingdom.rank_class = Ranks.lookup(:iczn, 'subphylum')
        kingdom.valid?
        expect(kingdom.errors.include?(:rank_class)).to be_truthy
      end

      specify 'a parent from different project' do
        t = FactoryBot.create(:iczn_kingdom)
        t.valid?
        expect(t.errors.include?(:project_id)).to be_falsey
        t.project_id = 1000
        t.valid?
        expect(t.errors.include?(:project_id)).to be_truthy
      end
    end

    specify 'name' do
      expect(protonym.errors.include?(:name)).to be_truthy
    end

    context 'latinization requires' do 
      let(:error_message) {  'Name must be latinized, no digits or spaces allowed' }
      specify 'no digits are present at end' do
        protonym.name = 'aus1'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end

      specify 'no digits are present at start' do
        protonym.name = '1bus'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end

      specify 'no digits are present in middle' do
        protonym.name = 'au1s'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end
        
      specify 'no spaces are present' do
        protonym.name = 'ab us'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end
    end
  end
  
  context 'usage' do
    before(:each) do
      @f = FactoryBot.create(:relationship_family, name: 'Aidae', parent: @order)
      @g = FactoryBot.create(:relationship_genus, name: 'Aus', parent: @f)
      @o = FactoryBot.create(:relationship_genus, name: 'Bus', parent: @f)
      @s = FactoryBot.create(:relationship_species, name: 'aus', parent: @g)
    end

    specify 'assign an original description genus' do
      expect(@s.original_genus = @o).to be_truthy
      expect(@s.save).to be_truthy
      expect(@s.original_genus_relationship.class).to eq(TaxonNameRelationship::OriginalCombination::OriginalGenus)
      expect(@s.original_genus_relationship.subject_taxon_name).to eq(@o)
      expect(@s.original_genus_relationship.object_taxon_name).to eq(@s)
    end

    specify 'has at most one original description genus' do
      expect(@s.original_combination_relationships.count).to eq(0)
      # Example 1) recasting
      temp_relation = FactoryBot.create(
        :taxon_name_relationship,
        subject_taxon_name: @o,
        object_taxon_name: @s,
        type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      
      # Recast as the subclass
      # first_original_genus_relation = temp_relation.becomes(temp_relation.type_class)
      expect(@s.original_combination_relationships.count).to eq(1)

      # Example 2) just use the right subclass to start
      first_original_subgenus_relation = FactoryBot.create(
        :taxon_name_relationship_original_combination,
        subject_taxon_name: @g,
        object_taxon_name: @s,
        type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
      expect(@s.original_combination_relationships.count).to eq(2)

      extra_original_genus_relation = FactoryBot.build(
        :taxon_name_relationship,
        subject_taxon_name: @g,
        object_taxon_name: @s,
        type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      expect(extra_original_genus_relation.valid?).to be_falsey
      expect(@s.original_combination_relationships.count).to eq(2)
    end

    specify 'assign a type species to a genus' do
      expect(@g.type_species = @s).to be_truthy
      expect(@g.save).to be_truthy

      expect(@g.type_species_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_species_relationship.subject_taxon_name).to eq(@s)
      expect(@g.type_species_relationship.object_taxon_name).to eq(@g)
      expect(@g.type_taxon_name_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_taxon_name.name).to eq('aus')
      expect(@s.type_of_relationships.first.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@s.type_of_relationships.first.object_taxon_name).to eq(@g)
    end

    specify 'synonym has at most one valid name' do
      genus = FactoryBot.create(:relationship_genus, name: 'Cus', parent: @f)
      genus.iczn_set_as_subjective_synonym_of = @g
      expect(genus.save).to be_truthy
      genus.iczn_set_as_synonym_of = @o
      expect(genus.save).to be_truthy
      expect(genus.taxon_name_relationships.size).to be(1)
    end
  end

  context 'latinization' do
    let(:invalid_spelling) { Protonym.new(name: '1234', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
    context 'with invalid spelling' do

      specify 'does not #have_latinized_exceptions?' do
        expect(invalid_spelling.has_latinized_exceptions?).to be_falsey
      end

      specify 'is not #is_latin?' do
        expect(invalid_spelling.is_latin?).to be_falsey
      end

      specify '#have_latinized_exceptions?' do
        invalid_spelling.taxon_name_classifications << EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS.first.constantize.new
        invalid_spelling.save
        expect(invalid_spelling.has_latinized_exceptions?).to be_truthy
      end

      context 'when rank ICZN family' do
        let(:family) { Protonym.new(name: 'Fooidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: root) }
        specify "is validly_published when ending in '-idae'" do
          family.valid?
          expect(family.errors.include?(:name)).to be_falsey
        end

        specify "is invalidly_published when not ending in '-idae'" do
          t = Protonym.new(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'family'))
          t.valid?
          expect(t.errors.include?(:name)).to be_truthy
        end
        specify "is validly_published when it is family group name form" do
          t1 = Protonym.create(name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: root)
          t = Protonym.new(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'family'), parent: root)
          t2 = t.taxon_name_relationships.new(object_taxon_name: t1, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm')
          t.valid?
          expect(t.errors.include?(:name)).to be_falsey
        end


        specify 'is invalidly_published when not capitalized' do
          protonym.name       = 'fooidae'
          protonym.rank_class = Ranks.lookup(:iczn, 'family')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_truthy
        end

        specify 'species name starting with upper case' do
          protonym.name       = 'Aus'
          protonym.rank_class = Ranks.lookup(:iczn, 'species')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_truthy
        end
      end

      context 'when rank ICN family' do
        specify "is validly_published when ending in '-aceae'" do
          protonym.name = 'Aaceae'
          protonym.rank_class = Ranks.lookup(:icn, 'family')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_falsey
        end
        specify "is invalidly_published when not ending in '-aceae'" do
          protonym.name = 'Aus'
          protonym.rank_class = Ranks.lookup(:icn, 'family')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_truthy
        end
      end
    end

    context 'with valid spelling' do
      before { invalid_spelling.name = 'Aus' }

      specify 'does not #have_latinized_exceptions?' do
        expect(invalid_spelling.has_latinized_exceptions?).to be_falsey
      end

      specify '#is_latin?' do
        expect(invalid_spelling.is_latin?).to be_truthy
      end
    end
  end

  context 'parallel creation of OTUs' do
    let(:p) {Protonym.new(parent: @order , name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus')) }

    specify '#also_create_otu with new creates an otu after_create' do
      expect(Otu.count).to eq(0) 
      p.also_create_otu = true
      p.save!
      expect(Otu.first.taxon_name_id).to eq(p.id)
    end

    specify '#also_create_otu does not create on save' do
      p.save!
      p.also_create_otu = true
      p.save!
      expect(Otu.count).to eq(0)
    end
  end

  context 'nominotypical detection' do
    let(:g1) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
    let(:g2) { Protonym.create!(name: 'Aus', parent: g1, rank_class: Ranks.lookup(:iczn, :subgenus)) }

    let(:s1) { Protonym.create!(name: 'aus', parent: root, rank_class: Ranks.lookup(:iczn, :species)) }
    let(:s2) { Protonym.create!(name: 'aus', parent: s1, rank_class: Ranks.lookup(:iczn, :subspecies)) }

    specify 'list_of_coordinated_names' do
      g3 = Protonym.create!(name: 'Aus', parent: g1, rank_class: Ranks.lookup(:iczn, :subgenus))
      c1 = TaxonNameClassification::Iczn::Unavailable::NomenNudum.create!(taxon_name: g3)
      g1.reload
      expect(g3.cached_is_valid).to be_falsey
      expect(g3.list_of_coordinated_names.count).to eq(0)
      expect(g2.list_of_coordinated_names.count).to eq(1)
      expect(g1.list_of_coordinated_names.count).to eq(1)
    end

    specify '#nominotypical_sub_of? 1' do
      expect(g1.nominotypical_sub_of?(g2)).to be_falsey
    end

    specify '#nominotypical_sub_of? 2' do
      expect(g2.nominotypical_sub_of?(g1)).to be_truthy
    end

    specify '#nominotypical_sub_of? 3' do
      expect(s1.nominotypical_sub_of?(s2)).to be_falsey
    end

    specify '#nominotypical_sub_of? 4' do
      expect(s2.nominotypical_sub_of?(s1)).to be_truthy
    end
  end

  context 'citation' do
    let!(:g1) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }

    context 'original citation via nested attributes' do
      let!(:c) { Citation.create(citation_object: g1, source: s, is_original: true) }
      let(:s) { FactoryBot.create(:valid_source_bibtex) }
      specify 'destroying original citation as nested attributes' do
        expect( g1.reload.origin_citation.nil?).to be_falsey
        expect( g1.update!(origin_citation_attributes: {id: c.id, _destroy: true} ) ).to be_truthy
        expect( g1.reload.origin_citation.nil?).to be_truthy
      end
    end

    context 'verbatim references' do
      let(:v) { FactoryBot.create(:valid_source_verbatim) } 
      specify 'are not allowed via nested attributes' do
        expect(g1.update(origin_citation_attributes: { source_id: v.id })).to be_falsey
      end
    end
  end

  context 'predict three name forms' do
    use_cases = {
        'albus'     => 'albus|alba|album',
        'alba'      => 'albus|alba|album',
        'album'     => 'albus|alba|album',
        'niger'     => 'niger|nigra|nigrum',
        'nigra'     => 'niger|nigra|nigrum',
        'nigrum'    => 'niger|nigra|nigrum',
        'viridis'   => 'viridis|viridis|viride',
        'viride'    => 'viridis|viridis|viride',
        'major'     => 'major|major|majus',
        'majus'     => 'major|major|majus',
        'minor'     => 'minor|minor|minus',
        'minus'     => 'minor|minor|minus',
        'bicolor'   => 'bicolor|bicolor|bicolor',
        'bicoloris' => 'bicoloris|bicoloris|bicoloris',
        'acer'      => 'acer|acris|acre',
        'acris'     => 'acer|acris|acre',
        'acre'      => 'acer|acris|acre',
        'cefera'    => 'cefer|cefera|ceferum',
        'ceferum'   => 'cefer|cefera|ceferum',
        'cegera'    => 'ceger|cegera|cegerum',
        'cegerum'   => 'ceger|cegera|cegerum',
        'glaber'    => 'glaber|glabra|glabrum',
        'glabra'    => 'glaber|glabra|glabrum',
        'glabrum'   => 'glaber|glabra|glabrum',
        'ater'      => 'ater|atra|atrum',
        'atra'      => 'ater|atra|atrum',
        'atrum'     => 'ater|atra|atrum',
        'pedestris' => 'pedester|pedestris|pedestre',
        'mirus'     => 'mirus|mira|mirum',
        'mira'      => 'mirus|mira|mirum',
        'mirum'     => 'mirus|mira|mirum',
        'integer'   => 'integer|integra|integrum',
        'integra'   => 'integer|integra|integrum',
        'integrum'  => 'integer|integra|integrum',
        'asper'     => 'asper|aspera|asperum',
        'aspera'    => 'asper|aspera|asperum',
        'asperum'   => 'asper|aspera|asperum',
    }

    @entry = 0

    use_cases.each { |name, result|
      @entry += 1
      specify "case #{@entry}: '#{name}' should yield #{result}" do
        t = FactoryBot.build(:relationship_species, name: name, parent: nil)
        forms = t.predict_three_forms
        u = forms[:masculine_name].to_s + '|' +
            forms[:feminine_name].to_s + '|' +
            forms[:neuter_name].to_s
        expect(u).to eq(result)
      end
    }
  end

end
