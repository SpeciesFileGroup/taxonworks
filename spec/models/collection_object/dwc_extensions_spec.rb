require 'rails_helper'
describe CollectionObject::DwcExtensions, type: :model, group: [:collection_objects, :darwin_core] do

  specify 'dwc_georeferenced_by 1' do
    p1 = Person.create!(last_name: 'Jones')
    p2 = Person.create!(last_name: 'Janes')

    g = FactoryBot.create(:valid_georeference, georeferencers: [p1,p2])
    s = Specimen.create!(collecting_event: g.collecting_event)
    expect(s.dwc_georeferenced_by).to eq(p1.cached + '|' + p2.cached)
  end

  specify 'dwc_georeferenced_by 2' do
    g = FactoryBot.create(:valid_georeference)
    s = Specimen.create!(collecting_event: g.collecting_event)
    expect(s.dwc_georeferenced_by).to eq(g.creator.name)  #
  end

  specify 'is_fossil? no' do
    s = Specimen.create!
    expect(s.is_fossil?).to eq(false)
  end

  specify 'is_fossil? yes' do
    s = Specimen.create!
    c = FactoryBot.create(:valid_biocuration_class, uri: DWC_FOSSIL_URI)
    s.biocuration_classes << c
    expect(s.is_fossil?).to eq(true)
  end

  context '#dwc_occurrence' do
    let!(:ce) { CollectingEvent.create!(start_date_year: '2010') }
    let!(:s) { Specimen.create!(collecting_event: ce) }
    let(:p) { Person.create!(last_name: 'Smith', first_name: 'Sue') }
    let(:o) { Otu.create!(name: 'Barney') }

    let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }

    specify '#dwc_decimal_latitude' do
      a = Georeference::Wkt.create!(collecting_event: ce, wkt: 'POINT(9.0 60)' )

      s.georeference_attributes(true) # force the rebuild
      expect(s.dwc_decimal_latitude).to eq(60.0) # technically not correct significant figures :(
    end

    specify '#dwc_year' do
      expect(s.dwc_year).to eq(2010)
    end

    specify '#dwc_month' do
      ce.update!( start_date_month: 1)
      expect(s.dwc_month).to eq(1)
    end

    specify '#dwc_month' do
      ce.update!( start_date_month: 1, start_date_day: 10)
      expect(s.dwc_day).to eq(10)
    end

    specify '#dwc_start_day_of_year' do
      ce.update!( start_date_month: 1, start_date_day: 1)
      expect(s.dwc_start_day_of_year).to eq(1)
    end

    specify '#dwc_end_day_of_year' do
      ce.update!(start_date_year: 2000, start_date_month: 12, start_date_day: 31, end_date_year: 2000, end_date_month: 12, end_date_day: 31)
      expect(s.dwc_end_day_of_year).to eq(366) # leap
    end

    specify '#dwc_event_date 1' do
      expect(s.dwc_event_date).to eq('2010')
    end

    specify '#dwc_event_date 2' do
      ce.update!(
        start_date_month: 1,
        start_date_day: 2
      )
      expect(s.dwc_event_date).to eq('2010-01-02')
    end

    specify '#dwc_event_date 2' do
      ce.update!(
        start_date_month: 1,
        start_date_day: 2,
        end_date_year: 2011,
        end_date_month: 1,
        end_date_day: 1
      )
      expect(s.dwc_event_date).to eq('2010-01-02/2011-01-01')
    end

    specify 'exists after create' do
      expect(s.dwc_occurrence).to be_truthy
    end

    specify 'updates after related CE save' do
      ce.update!(start_date_year: 2012)
      expect(s.dwc_occurrence.reload.eventDate).to match('2012')
    end

    specify 'ce save is fine' do
      expect(ce.save).to be_truthy
    end

    specify 'ce update' do
      expect(ce.update(
        'verbatim_label' => '74',
        'roles_attributes' => []
      )).to be_truthy
    end

    specify 'specimen save' do
      expect(s.update!(total: 4)).to be_truthy
    end

    # Not sure of point of these now without downstream checks
    specify 'update dwc_occurrence' do
      d = DwcOccurrence.find(s.dwc_occurrence.id)
      expect(d.update!(year: 2000)).to be_truthy
    end

    # Not sure of point of these now without downstream checks
    context 'with taxon determination' do
      let!(:o) { Otu.create!(name: 'Blob') }
      let!(:td) { TaxonDetermination.create!(biological_collection_object: s, otu: o) }

      specify 'taxon determination update' do
        expect(td.update!(otu: Otu.create!(name: 'Aus'))).to be_truthy
      end
    end

    context '2 objects per ce' do
      let(:s2) { Specimen.create!(collecting_event: ce ) }

      specify 'ce.save with 2 specimens' do
        expect(ce.update!(start_date_year: 2012)).to be_truthy
      end

      specify 's2.update' do
        expect(s2.update!(total: 10)).to be_truthy
      end
    end

    specify '#dwc_identified_by' do
      TaxonDetermination.create!(biological_collection_object: s, otu: o, roles_attributes: [{person: p, type: 'Determiner'}])
      s.reload # why is it c
      expect(s.dwc_identified_by).to eq('Smith, Sue')
    end

    specify '#dwc_date_identified' do
      FactoryBot.create(:valid_taxon_determination, biological_collection_object: s, year_made: 2000, day_made: 1, month_made: 1 )
      s.reload
      expect(s.dwc_date_identified).to eq('2000-1-1')
    end

    specify '#dwc_type_status' do
      a = FactoryBot.create(:valid_type_material, collection_object: s)
      a.protonym.update!(original_genus: a.protonym.parent)
      a.protonym.update!(original_species: a.protonym )

      expect(s.dwc_type_status).to eq('holotype of Erythroneura vitis McAtee, 1900')
    end

    specify '#dwc_kingdom' do
      p = Protonym.create!(
        name: 'Animalia',
        rank_class: Ranks.lookup(:iczn, :kingdom),
        parent: Project.find(Current.project_id).send(:create_root_taxon_name)
      )

      d = TaxonDetermination.create!(
        biological_collection_object: s,
        otu: Otu.create!(taxon_name: p)
      )

      s.taxonomy(true)
      expect(s.dwc_kingdom).to eq('Animalia')
    end

    specify '#dwc_taxon_rank' do
      p = Protonym.create!(
        name: 'Aus',
        rank_class: Ranks.lookup(:iczn, :genus),
        parent: root
      )

      TaxonDetermination.create!(biological_collection_object: s, otu: Otu.create!(taxon_name: p))

      s.reload
      expect(s.dwc_taxon_rank).to eq('genus')
    end

    specify '#dwc_infraspecific_epithet' do
      p = Protonym.create!(
        name: 'aus',
        rank_class: Ranks.lookup(:iczn, :subspecies),
        parent: root
      )

      TaxonDetermination.create!(biological_collection_object: s, otu: Otu.create!(taxon_name: p))

      s.taxonomy(true)
      expect(s.dwc_infraspecific_epithet).to eq('aus')
    end

    specify '#dwc_verbatim_date' do
      ce.update!(verbatim_date: 'some date')
      expect(s.dwc_verbatim_event_date).to eq('some date')
    end

    specify '#dwc_verbatim_habitat' do
      ce.update!(verbatim_habitat: 'some habitat')
      expect(s.dwc_verbatim_habitat).to eq('some habitat')
    end

    specify '#dwc_sampling_protocol' do
      ce.update!(verbatim_method: 'some method')
      expect(s.dwc_sampling_protocol).to eq('some method')
    end

    specify '#dwc_field_number' do
      i = FactoryBot.create(:valid_identifier_local, type: 'Identifier::Local::TripCode', identifier_object: ce)
      expect(s.dwc_field_number).to eq(i.cached)
    end

    specify '#dwc_minimum_elevation_in_meters' do
      ce.update!(minimum_elevation: 123)
      expect(s.dwc_minimum_elevation_in_meters).to eq(123)
    end

    specify '#dwc_maximum_elevation_in_meters' do
      ce.update!(maximum_elevation: 456)
      expect(s.dwc_maximum_elevation_in_meters).to eq(456)
    end

    specify '#dwc_verbatim_elevation' do
      ce.update!(verbatim_elevation: 456)
      expect(s.dwc_verbatim_elevation).to eq('456')
    end

    specify '#dwc_verbatim_coordinates' do
      ce.update!(verbatim_latitude: '90', verbatim_longitude: '90')
      expect(s.dwc_verbatim_coordinates).to eq('90 90')
    end

    specify '#dwc_sex' do
      g = BiocurationGroup.create!(
        name: 'sex',
        definition: 'as defined by gamete count in some ontology',
        uri: 'http://rs.tdwg.org/dwc/terms/sex' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

      a = BiocurationClass.create!(
        name: 'gynandromorph',
        definition: 'physically representing > 1 sex?',
      )

      Tag.create!(keyword: g, tag_object: a)

      b = BiocurationClassification.create!(
        biological_collection_object: s,
        biocuration_class: a)

      expect(s.dwc_sex).to eq('gynandromorph')
    end

    specify '#dwc_life_stage' do
      g = BiocurationGroup.create!(
        name: 'sex',
        definition: 'as defined by gamete count in some ontology',
        uri: 'http://rs.tdwg.org/dwc/terms/lifeStage' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

      a = BiocurationClass.create!(
        name: 'adult',
        definition: 'reaaaaaaal mature person',
      )

      Tag.create!(keyword: g, tag_object: a)

      b = BiocurationClassification.create!(
        biological_collection_object: s,
        biocuration_class: a)

      expect(s.dwc_life_stage).to eq('adult')
    end

    specify '#dwc_water_body' do
      a = Predicate.create!(
        name: 'water body',
        definition: 'the name of the place with the H2O',
        uri: 'http://rs.tdwg.org/dwc/terms/waterBody' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

      b = InternalAttribute.create!(
        value: 'Lake Miss-again',
        predicate: a,
        attribute_subject: ce
      )
      expect(s.dwc_water_body).to eq('Lake Miss-again')
    end

    specify '#dwc_verbatim_depth' do
      d = 'reeeeeal deep'
      a = Predicate.create!(
        name: "Let's get deep",
        definition: 'depth of the deepness',
        uri: 'http://rs.tdwg.org/dwc/terms/verbatimDepth' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

      b = InternalAttribute.create!(
        value: d,
        predicate: a,
        attribute_subject: ce
      )
      expect(s.dwc_verbatim_depth).to eq(d)
    end

    specify '#dwc_maximum_dpeth_in_meters' do
      d = 2.1
      a = Predicate.create!(
        name: "wet toes?",
        definition: 'number in metric m, not that other standard',
        uri: 'http://rs.tdwg.org/dwc/terms/maximumDepthInMeters' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

      b = InternalAttribute.create!(
        value: d,
        predicate: a,
        attribute_subject: ce
      )
      expect(s.dwc_maximum_depth_in_meters).to eq(d.to_s)
    end

    specify '#dwc_minimum_dpeth_in_meters' do
      d = 2.1
      a = Predicate.create!(
        name: "wet toes?",
        definition: 'number in metric m, not that other standard',
        uri: 'http://rs.tdwg.org/dwc/terms/minimumDepthInMeters' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

      b = InternalAttribute.create!(
        value: d,
        predicate: a,
        attribute_subject: ce
      )
      expect(s.dwc_minimum_depth_in_meters).to eq(d.to_s)
    end

    specify '#dwc_previous_identifications' do
      p1 = Protonym.create!(
        name: 'aus',
        rank_class: Ranks.lookup(:iczn, :species),
        parent: root
      )

      p2 = Protonym.create!(
        name: 'bus',
        rank_class: Ranks.lookup(:iczn, :species),
        parent: root
      )

      TaxonDetermination.create!(biological_collection_object: s, otu: Otu.create!(taxon_name: p1), year_made: 2020)
      TaxonDetermination.create!(biological_collection_object: s, otu: Otu.create!(taxon_name: p2) )

      s.taxonomy(true)
      s.reload
      expect(s.dwc_previous_identifications).to eq('[GENUS NOT SPECIFIED] aus on 2020')
    end

    specify '#dwc_recorded_by' do
      p1 = Protonym.create!(
        name: 'aus',
        rank_class: Ranks.lookup(:iczn, :species),
        parent: root
      )

      ce.update!(collectors_attributes: [{last_name: 'Doe', first_name: 'John'}])
      TaxonDetermination.create!(biological_collection_object: s, otu: Otu.create!(taxon_name: p1), determiner_roles_attributes: [{person: p}] )

      s.reload

      expect(s.dwc_recorded_by).to eq('Doe, John')
    end

    specify '#dwc_other_catalog_numbers' do
      a = Identifier::Local::CatalogNumber.create!(identifier: '123', identifier_object: s, namespace: FactoryBot.create(:valid_namespace) )
      b = Identifier::Local::CatalogNumber.create!(identifier: '456', identifier_object: s, namespace: FactoryBot.create(:valid_namespace) )
      c = Identifier::Local::CatalogNumber.create!(identifier: '790', identifier_object: s, namespace: FactoryBot.create(:valid_namespace) )
      expect(s.dwc_other_catalog_numbers).to eq("#{b.cached} | #{a.cached}")
    end

    specify '#dwc_associated_media' do
      i = FactoryBot.create(:valid_depiction, depiction_object: s)
      j = FactoryBot.create(:valid_depiction, depiction_object: s)
      a = i.image
      b = j.image


      p = 'http://127.0.0.1:3000/api/v1/images'

      s.images.reload
      expect(s.dwc_associated_media).to eq("#{p}/#{a.image_file_fingerprint} | #{p}/#{b.image_file_fingerprint}")
    end

  end
end

