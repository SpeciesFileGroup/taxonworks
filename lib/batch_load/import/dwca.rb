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
        make_tn:    %w(scientificname taxonrank family kingdom),
        make_td:    %w(),
        make_otu:   %w(scientificname),
        make_co:    %w(basisofrecord individualcount organismquantity organismquantitytype recordedby),
        make_notes: %w(catalognumber),
        make_gr:    %w(decimallatitude decimallongitude countrycode stateprovince county municipality coordinateuncertaintyinmeters georeferencedby),
        make_ce:    %w(coordinateuncertaintyinmeters verbatimlocality eventdate recordedby locationremarks geodeticdatum)
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

        otu     = @row_objects[:make_otu]
        t_d     = @row_objects[:make_td]
        c_o     = @row_objects[:make_co]
        c_e     = @row_objects[:make_ce]
        g_l     = @row_objects[:make_gr]
        species = @row_objects[:make_tn][:species]
        genus   = @row_objects[:make_tn][:genus]
        tribe   = @row_objects[:make_tn][:tribe]
        t_n     = @row_objects[:make_tn].select {|kee, val| val != nil}.values.first
        # if species.nil?
        #   if genus.nil?
        #     t_n = tribe
        #   else
        #     t_n = genus
        #   end
        # else
        #   t_n = species
        # end

        t_n.save! if t_n.new_record?
        otu.taxon_name = t_n
        otu.save!
        c_e.save!
        c_o.collecting_event = c_e
        c_o.save!
        t_d.biological_collection_object = c_o
        t_d.otu                          = otu
        t_d.save!
        g_l.collecting_event = c_e
        g_l.save!

        messages = []
        begin # make sure all objects for this row get saved
          @row_objects.keys.each {|kee|
            objects = @row_objects[kee]
            case objects.class.to_s
              when 'Array'
                objects.each {|object|
                  if object.valid?
                    object.save
                  else
                    messages.push(object.errors.messages)
                  end
                }
              when 'Hash'
                objects.keys.each {|rank|
                  object = objects[rank]
                  unless object.blank?
                    if object.valid?
                      object.save
                    else
                      messages.push(object.errors.messages)
                    end
                  end
                }
              else
                if objects.valid?
                  objects.save
                else
                  messages.push(objects.errors.messages)
                end
            end
          }
          messages
        end
        line_counter += 1
      end
      @total_lines = line_counter - 1
    end

    def pilgrim # TODO: remove when result cycler is finished.
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
      @root.save! if @root.new_record?
      @kingdom = Protonym.find_or_create_by(name:       'Animalia',
                                            parent_id:  @root.id,
                                            rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
                                            project_id: $project_id)
      @kingdom.save! if @kingdom.new_record?
      @controlled_vocabulary_term = ControlledVocabularyTerm.find_or_create_by(name:       'catalogNumber',
                                                                               type:       'Predicate',
                                                                               definition: 'The verbatim value imported from PSUC for "catalogNumber".',
                                                                               project_id: $project_id)
      @controlled_vocabulary_term.save! if @controlled_vocabulary_term.new_record?
    end

    def make_gr(row)
      # faking a Georeference::GeoLocate:
      lat, long           = row['decimallatitude'], row['decimallongitude']
      # lat, long           = (lat.length > 0) ? lat : nil, (long.length > 0) ? long : nil
      uncert              = row['coordinateuncertaintyinmeters']
      cc                  = row['countrycode']
      country             = cc.nil? ? nil : GeographicArea.where(iso_3166_a2: cc).first.name
      gl_req_params       = {country:   country,
                             state:     row['stateprovince'],
                             county:    row['county'],
                             Placename: row['municipality'],
                             Uncert:    uncert,
                             Latitude:  lat,
                             Longitude: long,
                             locality:  row['locality'],
                             gc:        row['georeferencedby']}.stringify_keys
      req                 = Georeference::GeoLocate::RequestUI.new(gl_req_params)
      #   1) new the Georeference, without a collecting_event
      g_l                 = Georeference::GeoLocate.new
      #   2) save the information from the row in request_hash
      g_l.api_request     = req.request_params_string
      #   3) build a fake iframe response in the form '52.65|-106.333333|3036|Unavailable'
      text                = "#{lat}|#{long}|#{uncert}|Unavailable"
      #   4) use that fake to stimulate the parser to create the object
      g_l.iframe_response = text

      g_l
    end

    def make_notes(row)
      cat_no = row['catalognumber']
      if Note.find_or_create_by(text:             cat_no,
                                note_object_type: 'CollectionObject',
                                project_id:       project_id)

      end

# available data comes from Tulane geolocation action, reflected by the fact that the georefernce is a GeoLocate
      def make_ce(row)
        c_e = CollectingEvent.new(verbatim_datum:                   row['geodeticdatum'],
                                  verbatim_locality:                row['verbatimlocality'],
                                  verbatim_date:                    row['eventdate'],
                                  verbatim_label:                   row['locationremarks'],
                                  verbatim_geolocation_uncertainty: row['coordinateuncertaintyinmeters']
        )


        c_e
      end

      def make_otu(row)
        Otu.new
      end

#         make_co:  %w(catalognumber basisofrecord individualcount organismquantity organismquantitytype recordedby),
      def make_co(row)
        c_o = Specimen.new(total: row[:organismquantity])

        c_o
      end

      def make_tn(row)
        ret_val      = {species: nil, genus: nil, tribe: nil}
        this_kingdom = row['kingdom']
        if @kingdom.try(:name) != this_kingdom
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
        if @family.try(:name) != this_family
          @family = Protonym.find_or_create_by(name:       this_family,
                                               rank_class: NomenclaturalRank::Iczn::FamilyGroup::Family,
                                               project_id: $project_id)
          if @family.new_record?
            @family.parent = @kingdom
            @family.save!
            ret_val[:family] = @family
          end
        end
        sn        = row['scientificname']
        snp       = @parser.parse(sn)

        # find or create Protonym based on exact match of row['scientificname'] and taxon_names.cached

        t_n       = Protonym.find_or_create_by(cached: snp[:scientificName][:canonical], project_id: $project_id)
        this_rank = row['taxonrank'].downcase.to_sym

        if t_n.new_record?
          case this_rank
            when :species
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
            when :genus
              genus           = snp[:scientificName][:details][0][:uninomial]
              t_n.parent      = @family
              t_n.rank_class  = NomenclaturalRank::Iczn::GenusGroup::Genus
              t_n.name        = genus[:string]
              ret_val[:genus] = t_n
            when :tribe
              tribe           = snp[:scientificName][:details][0][:uninomial]
              t_n.parent      = @family
              t_n.rank_class  = NomenclaturalRank::Iczn::FamilyGroup::Tribe
              t_n.name        = tribe[:string]
              ret_val[:tribe] = t_n
            else
              raise "Unknown taxonRank #{this_rank}."
          end
          # t_n.create_otu
        else
          ret_val[this_rank] = t_n
        end

        # t_n = Protonym.new(name:               snp[:scientificName][:canonical],
        #                     cached_author_year: ,
        #                     parent_id:          ,
        #                     rank_class:         ,
        #                     also_create_otu:    true)
        ret_val
      end

      def make_td(row)
        TaxonDetermination.new
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

