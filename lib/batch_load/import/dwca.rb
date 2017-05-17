module BatchLoad
  # TODO: Originally transliterated from Import::CollectingEvents: Remove this to-do after successful operation.
  class Import::DWCA < BatchLoad::Import

    attr_accessor :collecting_events

    attr_accessor :dwca_namespace

    attr_accessor :parser
    attr_accessor :tasks_

    attr_accessor :rows
    attr_accessor :row_objects

    def initialize(dwca_namespace: nil, **args)
      @collecting_events = {}
      @rows              = []
      @row_objects       = {}
      @dwca_namespace    = dwca_namespace
      @parser            = ScientificNameParser.new
      @tasks_            = {
        make_tn:  %w(scientificname taxonrank family kingdom),
        make_td:  %w(otherPile),
        make_otu: %w(pileMaker),
        make_co:  %w(catalognumber basisofrecord individualcount organismquantity organismquantitytype recordedby),
        make_ce:  %w(verbatimlocality eventdate decimallatitude decimallongitude countrycode recordedby locationremarks)
      }.freeze

      pre_load

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
        @row_objects = {}
        tasks.each {|task|
          @row_objects[task] = send(task, row)
        }

        c_o     = @row_objects[:make_co]
        c_e     = @row_objects[:make_ce]
        species = @row_objects[:make_tn][:species]
        if species.nil?
          t_n = @row_objects[:make_tn][:genus]
        else
          t_n = species
        end

        t_n.save!
        otu                  = Otu.create!(taxon_name: t_n)
        c_o.collecting_event = c_e
        t_d                  = TaxonDetermination.create!(biological_collection_object: c_o, otu: otu)

        line_counter += 1
      end
      @total_lines = line_counter - 1
    end

    def pilgram
      @row_objects.keys.each {|kee| # necessary actions are specified by keys
        @row_objects[kee].each {|item| # objects to correlate

          case kee
            when 'make_ce'
              item.save!
            when 'make_co'
              item.save!
            when 'make_tn'
              item.save!
              if item.otus.count < 1
                Otu.create(by: item.creator, project: item.project, taxon_name_id: item.id)
              end
              item.valid?
          end

          if item.valid?
            item.save!
          else
            line = item.errors.messages
            puts line
          end
        }
      }

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

# only for use in a TaxonWorks rails console
    def _setup
      $project    = Project.where(name: 'BatchLoad Test').first
      $project_id = $project.id
      $user       = User.find(185)
      $user_id    = $user.id
      @root       = Protonym.find_or_create_by(name:       'Root',
                                               rank_class: 'NomenclaturalRank',
                                               parent_id:  nil,
                                               project_id: $project_id)
      @animalia   = Protonym.find_or_create_by(name:       'Animalia',
                                               parent_id:  @root.id,
                                               rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
                                               project_id: $project_id)
    end

# what to do before you try to load the entire file
    def pre_load
      @root = Protonym.find_or_create_by(name:       'Root',
                                         rank_class: 'NomenclaturalRank',
                                         parent_id:  nil,
                                         project_id: $project_id)
      # @kingdom = Protonym.find_or_create_by(name:       'Animalia',
      #                                       parent_id:  @root.id,
      #                                       rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
      #                                       project_id: @project_id)
      @root.save!
    end

    def make_ce(row)
      lat, long = row['decimallatitude'], row['decimallongitude']
      c_e       = CollectingEvent.new(verbatim_latitude:  (lat.length > 0) ? lat : nil,
                                      verbatim_longitude: (long.length > 0) ? long : nil,
                                      verbatim_locality:  row['verbatimlocality'],
                                      verbatim_date:      row['eventlate'],
                                      verbatim_label:     row['locationlemarks']
      )

      c_e
    end

    def make_otu(row)
      'Otu'
    end

#         make_co:  %w(catalognumber basisofrecord individualcount organismquantity organismquantitytype recordedby),
    def make_co(row)
      c_o = Specimen.new(total: row[:organismquantity])
      c_o
    end

    def make_tn(row)
      ret_val      = {species: nil, genus: nil}
      this_kingdom = row['kingdom']
      unless @kingdom.try(:name) == this_kingdom
        @kingdom = Protonym.find_or_create_by(name:       this_kingdom,
                                              rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
                                              project_id: $project_id)

        if @kingdom.new_record?
          @kingdom.parent = @root
          @kingdom.save!
          ret_val[:kingdom] = @kingdom
        end
      end

      this_family = row['family']
      unless @family.try(:name) == this_family
        @family = Protonym.find_or_create_by(name:       this_family,
                                             rank_class: NomenclaturalRank::Iczn::FamilyGroup::Family,
                                             project_id: $project_id)
        if @family.new_record?
          @family.parent = @kingdom
          @family.save!
          ret_val[:family] = @family
        end
      end
      sn  = row['scientificname']
      snp = @parser.parse(sn)

      # find or create Protonym based on exact match of row['scientificname'] and taxon_names.cached

      t_n = Protonym.find_or_create_by(cached: snp[:scientificName][:canonical], project_id: $project_id)

      if t_n.new_record?
        case row['taxonrank'].downcase
          when 'species'
            begin # find or create genus
              genus_name = snp[:scientificName][:details][0][:genus][:string]
              @genus     = Protonym.find_or_create_by(name:       genus_name,
                                                      parent:     @family,
                                                      rank_class: NomenclaturalRank::Iczn::GenusGroup::Genus,
                                                      project_id: $project_id)
              if @genus.new_record?
                @genus.save!
                ret_val[:new_genus] = @genus
              end
            end
            species                 = snp[:scientificName][:details][0][:species]
            t_n.parent              = @genus
            t_n.rank_class          = NomenclaturalRank::Iczn::SpeciesGroup::Species
            t_n.name                = species[:string]
            # t_n.cached_author_year = snp[:scientificName][:details][0][:species][:authorship]
            t_n.year_of_publication = species[:basionymAuthorTeam][:year].to_i
            author_name             = species[:basionymAuthorTeam][:authorTeam]
            if species[:authorship].include?('(')
              author_name = "(#{author_name})"
            end
            t_n.verbatim_author = author_name
            ret_val[:species]   = t_n
          when 'genus'
            genus           = snp[:scientificName][:details][0][:uninomial]
            t_n.parent      = @family
            t_n.rank_class  = NomenclaturalRank::Iczn::GenusGroup::Genus
            t_n.name        = genus[:string]
            ret_val[:genus] = t_n
        end
        # t_n.create_otu
      else
        if t_n.otus.count < 1
          # t_n.create_otu
        end
      end

      # t_n = Protonym.new(name:               snp[:scientificName][:canonical],
      #                     cached_author_year: ,
      #                     parent_id:          ,
      #                     rank_class:         ,
      #                     also_create_otu:    true)
      ret_val
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

