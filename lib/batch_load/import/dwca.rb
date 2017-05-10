module BatchLoad
  # TODO: Originally transliterated from Import::CollectingEvents: Remove this to-do after successful operation.
  class Import::DWCA < BatchLoad::Import

    attr_accessor :collecting_events

    attr_accessor :dwca_namespace

    attr_accessor :parser
    attr_accessor :tasks_

    def initialize(dwca_namespace: nil, **args)
      @collecting_events = {}
      @dwca_namespace    = dwca_namespace
      @parser            = ScientificNameParser.new
      @tasks_            = {
        make_tn:  %w(scientificName taxonRank family kingdom),
        make_td:  %w(otherPile),
        make_otu: %w(pileMaker),
        make_co:  %w(catalogNumber basisOfRecord individualCount organismQuantity organismQuantityType recordedBy),
        make_ce:  %w(verbatimLocality eventDate decimalLatitude decimalLongitude countryCode recordedBy locationRemarks)
      }.freeze
      super(args)
    end

    def preview_dwca
      @preview_table = {}

      @preview_table
    end

=begin  Headers from PSUC DWCS
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
# process each row for information:
    def build_dwca
      line_counter = 1 # accounting for headers

      tasks = triage(csv.headers, tasks_)
      csv.each do |row|
        tasks.each {|task|
          send(task, row)
        }
        line_counter += 1
      end
      @total_lines = line_counter - 1
    end

    def build
      if valid?
        build_dwca
        @processed = true
      end
    end

    def create

    end

    private

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

