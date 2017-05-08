require 'fileutils'

namespace :tw do
  namespace :project_import do
    namespace :penn_state do
      namespace :dwca do

        desc 'Import Penn State DWCA speciman data.'
        task import_dwca: [:file, :environment] do
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
          tasks = {
            record_ce: []
          }
          text  = File.read(ENV['file'])
          csv   = CSV.parse(text, {headers: true, col_sep: "\t"})

          csv.each {|row|
            ap(row)
          }
        end

        def triage(headers)
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
        end
      end
    end
  end
end
