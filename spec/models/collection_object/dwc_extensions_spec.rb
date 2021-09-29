require 'rails_helper'
describe CollectionObject::DwcExtensions, type: :model, group: :collection_objects do

  context '#dwc_occurrence' do
    let!(:ce) { CollectingEvent.create!(start_date_year: '2010') }
    let!(:s) { Specimen.create!(collecting_event: ce) }
    let(:p) { Person.create!(last_name: 'Smith', first_name: 'Sue') }
    let(:o) { Otu.create!(name: 'Barney') }

    let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }

    # Rough tests to detect infinite recursion

    specify '#dwc_event_date 1' do
      expect(s.dwc_event_date).to eq('2010')
    end

    specify '#dwc_event_date 2' do
      ce.update!(
        start_date_month: 1,
        start_date_day: 2
      )
      expect(s.dwc_event_date).to eq('2010/01/02')
    end

    specify '#dwc_event_date 2' do
      ce.update!(
        start_date_month: 1,
        start_date_day: 2,
        end_date_year: 2011,
        end_date_month: 1,
        end_date_day: 1
      )
      expect(s.dwc_event_date).to eq('2010/01/02-')
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
      FactoryBot.create(:valid_type_material, collection_object: s)
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
      a = BiocurationClass.create!(
        name: 'gynandromorph',
        definition: 'physically representing > 1 sex?',
        uri: 'http://rs.tdwg.org/dwc/terms/sex' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

      b = BiocurationClassification.create!(
        biological_collection_object: s,
        biocuration_class: a)

      expect(s.dwc_sex).to eq('gynandromorph')
    end

    specify '#dwc_life_stage' do
      a = BiocurationClass.create!(
        name: 'adult',
        definition: 'reaaaaaaal mature person',
        uri: 'http://rs.tdwg.org/dwc/terms/lifeStage' # see /config/initializers/constants/_controlled_vocabularies/dwc_attribute_uris.rb
      )

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

      ce.update!(collectors_attributes: [{last_name: 'James', first_name: 'James'}])
      TaxonDetermination.create!(biological_collection_object: s, otu: Otu.create!(taxon_name: p1), determiner_roles_attributes: [{person: p}] )

      s.reload

      expect(s.dwc_recorded_by).to eq('Smith, Sue | James, James')
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
      a = i.image.image_file.url
      b = j.image.image_file.url

      s.images.reload
      expect(s.dwc_associated_media).to eq("#{a} | #{b}")
    end

  end
end

