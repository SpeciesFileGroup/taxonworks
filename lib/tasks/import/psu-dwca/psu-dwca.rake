require 'fileutils'

namespace :tw do
  namespace :project_import do
    namespace :penn_state do
      namespace :dwca do

        # desc 'Import Penn State DWCA speciman data. Needs file, user_id, and project_id'
        task import_dwca: [:file, :with_user_and_project, :environment] do
=begin

    catalogNumber
    scientificName
    taxonRank
    family
    kingdom
    individualCount
    organismQuantity
    organismQuantityType
    basisOfRecord
    eventDate
    recordedBy
    verbatimLocality
    locationRemarks
    associatedTaxa
    occurrenceRemarks
    countryCode
    stateProvince
    county
    municipality
    locality
    decimalLatitude
    decimalLongitude
    coordinateUncertaintyInMeters
    georeferencedBy
    georeferenceProtocol
    georeferenceRemarks
    geodeticDatum
    collectionID
    occurrenceID

=end
          @parser = ScientificNameParser.new
          tasks_  = {
            make_tn:  %w(scientificName taxonRank family kingdom),
            make_td:  %w(otherPile),
            make_otu: %w(pileMaker),
            make_co:  %w(catalogNumber basisOfRecord individualCount organismQuantity organismQuantityType recordedBy),
            make_ce:  %w(verbatimLocality eventDate decimalLatitude decimalLongitude countryCode recordedBy locationRemarks)
          }
          parent  = TaxonName.find_or_create_by(name:       'Animalia',
                                                rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
                                                project_id: sessions_current_project_id)

          text = File.read(ENV['file'])
          csv  = CSV.parse(text, {headers: true, col_sep: "\t"})

          tasks = triage(csv.headers, tasks_)
          csv.each {|row|
            # ap(row)
            tasks.each {|task|
              send(task, row)}
          }
        end

        def make_ce(row)
          lat, long = row['decimalLatitude'], row['decimalLongitude']
          c_e       = CollectingEvent.new(verbatim_latitude:  (lat.length > 0) ? lat : nil,
                                          verbatim_longitude: (long.length > 0) ? long : nil,
                                          verbatim_locality:  row['verbatimLocality'],
                                          verbatim_date:      row['eventDate'],
                                          verbatim_label:     row['locationRemarks']
          )
          c_e.save!
          c_e
        end

        def make_otu(row)
          'Otu'
        end

        def make_co(row)
          'CollectionObject'
        end

        def make_tn(row)
          sn  = row['scientificName']
          snp = @parser.parse(sn)

          t_n = TaxonName.new(name:            snp[:scientificName][:canonical],
                              rank_class:      Ranks.lookup(:iczn, taxonRank),
                              also_create_otu: true)
          t_n.save!
          t_n
        end

        def make_td(row)
          'TaxonDetermination'
        end

=begin
          2.3.3 :057 > headers
          => ["a", "b", "c", "d", "e", "f"]
          2.3.3 :058 > mthds
          => {:foo=>["a", "b"], :bar=>["d", "e"], :blorf=>["f", "z"]}
          2.3.3 :059 > mthds.select{|k,v| v & headers == v}
          => {:foo=>["a", "b"], :bar=>["d", "e"]}
          2.3.3 :060 > mthds.select{|k,v| v & headers == v}.keys
          => [:foo, :bar]
          2.3.3 :061 >
=end
        def triage(headers, tasks)
          tasks.select {|kee, vlu| vlu & headers == vlu}.keys
        end
      end
    end
  end
end
