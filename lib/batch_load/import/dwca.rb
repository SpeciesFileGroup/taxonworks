module BatchLoad
  # TODO: Originally transliterated from Import::CollectingEvents: Remove this to-do after successful operation.
  class Import::DWCA < BatchLoad::Import

    attr_accessor :collecting_events

    attr_accessor :dwca_namespace
    attr_accessor :repo

    attr_accessor :parser
    attr_accessor :tasks_

    attr_accessor :rows
    attr_accessor :row_objects

    def initialize(dwca_namespace: nil, **args)
      @dwca_namespace    = dwca_namespace
      @root              = args.delete(:root)
      @kingdom           = args.delete(:kingdom)
      @cat_no_pred       = args.delete(:cat_no_pred)
      @geo_rem_kw        = args.delete(:geo_rem_kw)
      @repo              = args.delete(:repo)
      @namespace         = args.delete(:namespace)
      @collecting_events = {}
      @rows              = {}
      @row_objects       = {}
      @parser            = ScientificNameParser.new
      @tasks_            = {
        make_ident: %w(catalognumber occurrenceid),
        make_prsn:  %w(georeferencedby),
        make_tn:    %w(scientificname taxonrank family kingdom),
        make_td:    %w(scientificname basisofrecord individualcount organismquantity organismquantitytype recordedby),
        # make_otu:   %w(scientificname),
        make_co:    %w(individualcount organismquantity organismquantitytype),
        make_ba:    %w(associatedtaxa),
        make_notes: %w(georeferenceremarks locationremarks occurrenceremarks),
        make_tag:   %w(),
        make_gr:    %w(decimallatitude decimallongitude countrycode stateprovince county municipality locality coordinateuncertaintyinmeters georeferencedby),
        make_ce:    %w(decimallatitude decimallongitude coordinateuncertaintyinmeters eventdate locationremarks recordedby geodeticdatum countrycode stateprovince county municipality locality)
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
        @warns                    = []
        @errs                     = []
        @rows[line_counter]       = {}
        @rows[line_counter][:row] = row
        @row_objects              = {}
        tasks.each {|task|
          results            = send(task, row)
          @row_objects[task] = results
          warn               = results[:warn]
          err                = results[:err]
          @errs.push(results.delete(:err)) unless err.blank?
          @warns.push(results.delete(:warn)) unless warn.blank?
        }


        t_n = @row_objects[:make_tn].select {|kee, val| val != nil}.values.first
        # save the (possible new) taxon_name
        t_n.save! if t_n.new_record?
        # associate the taxon_name with the otu
        otu = Otu.find_or_create_by(taxon_name: t_n)
        otu.save! if otu.new_record?
        @row_objects[:make_otu] = otu

        t_d       = @row_objects[:make_td]
        c_o       = @row_objects[:make_co][:c_o]
        idents    = @row_objects[:make_ident]
        id_cat_no = idents[:id_cat_no]
        id_occ_id = idents[:id_occ_id]
        b_a_s     = @row_objects[:make_ba]
        notes     = @row_objects[:make_notes]
        c_o_notes = notes[:c_o]
        c_e_notes = notes[:c_e]
        g_r_notes = notes[:g_r]
        c_e       = @row_objects[:make_ce][:c_e]
        g_r       = @row_objects[:make_gr]
        ppl       = @row_objects[:make_prsn]

        unless c_e.valid?
          test_list = c_e.errors.keys
          if test_list.include?(:start_date_day) or
            test_list.include?(:start_date_month) or
            test_list.include?(:start_date_year) or
            test_list.include?(:end_date_day) or
            test_list.include?(:end_date_month) or
            test_list.include?(:end_date_year)
            @warns.push(c_e.errors.full_messages)
            @warns.push("eventDate (#{c_e.verbatim_date}) does not parse properly.")

            c_e.start_date_day   = nil
            c_e.start_date_month = nil
            c_e.start_date_year  = nil
            c_e.end_date_day     = nil
            c_e.end_date_month   = nil
            c_e.end_date_year    = nil
          end
        end

        if c_e.valid? # check c_e again
          c_e.save if c_e.new_record?
          unless c_e_notes.blank?
            apply_note = false
            c_e_notes.keys.each {|kee|
              c_e_n = c_e_notes[kee]
              if c_e.notes.present?
                c_e.notes.each {|note|
                  if note.text == c_e_n.text
                    # need to drop the object without warning
                    @row_objects[:make_notes][:c_e].delete(:remark)
                  else
                    apply_note = true
                  end
                }
              else
                apply_note = true
              end
              c_e_n.note_object = c_e if apply_note
            }
          end
        else
          @errs.push(c_e.errors.full_messages.flatten)
          # everything else is a fail.
          line_counter = loop_end(line_counter)
          next
        end
        # associate the collection_object with the collecting_event
        c_o.collecting_event = c_e
        # associate the namespace and catalog number with the collection_object
        if id_cat_no.blank?
          @warns.push('Missing catalog number.')
        else
          c_o.identifiers << id_cat_no
        end
        if id_occ_id.blank?
          # is a warning required?
        else
          c_o.identifiers << id_occ_id
        end
        c_o.repository = @repo
        c_o.save!
        # add the possible biological_associations, new? otu to collection_object
        unless b_a_s.blank?
          b_a_s.keys.each {|kee|
            b_a                                = b_a_s[kee]
            b_a.biological_association_subject = c_o
          }
        end
        # add notes to collection_object, if required
        unless c_o_notes.blank?
          c_o_notes.keys.each {|kee|
            c_o_notes[kee].note_object = c_o
          }
        end
        # associate the collection_object with the otu using the taxon_determiniation
        t_d.biological_collection_object = c_o
        t_d.otu                          = otu
        t_d.save!
        # associate the georeference with the collecting_event
        g_r.collecting_event = c_e
        # two different types of georeferences: verbatim, and geolocate
        if g_r.type.include?('Ver')
          # for verbatim_data, generate a new georeference using the collecting_event
          a = c_e.generate_verbatim_data_georeference
          if a.valid?
            # and replace the pre-built georeference
            g_r                    = c_e.georeferences.last
            @row_objects[:make_gr] = g_r
          else
            @warns.push(a.errors.full_messages)
            @row_objects.delete(:make_gr)
          end
        else
          # is a GeoLocate
          unless g_r.valid?
            # georeference was (0,0), will be dropped
            err_txt = 'Georeference::GeoLocate cannot be created, '
            if g_r.errors.messages[:collecting_event_id].present?
              # what to do here?
              @warns.push(err_txt + 'duplicate georeference')
            else
              @warns.push(err_txt + 'lat/long not valid.')
            end
            @row_objects.delete(:make_gr)
            unless g_r_notes.blank?
              @warns.push('Georeference::GeoLocate cannot be created, \'georeferenceRemark\' has been dropped.')
              @row_objects[:make_notes].delete(:g_r)
            end
          end
        end
        # add a georeferencer as required
        g_rer = ppl[:g_r]
        unless g_rer.blank?
          unless g_r.georeferencers.include?(g_rer)
            g_r.georeferencers << g_rer
          end
        end
        # add notes to georeference, if required
        unless g_r_notes.blank?
          apply_note = false
          g_r_notes.keys.each {|kee|
            g_r_n = g_r_notes[kee]
            if g_r.notes.present?
              g_r.notes.each {|note|
                if note.text == g_r_n.text
                  # need to drop the object without warning
                  @row_objects[:make_notes][:g_r].delete(:remark)
                else
                  apply_note = true
                end
              }
            else
              apply_note = true
            end
            g_r_n.note_object = g_r if apply_note
          }
        end
        # either the original, or the ce-created one gets saved
        # g_r.save

        begin # make sure all objects for this row get saved
          @row_objects.keys.each {|kee|
            objects = @row_objects[kee]
            case objects.class.to_s
              when 'Array'
                objects.flatten.each {|object|
                  if object.valid?
                    object.save
                  else
                    @errs.push(object.errors.full_messages)
                  end
                }
              when 'Hash'
                @errs.push(save_hash(objects))
              else # all other single object classes
                test = objects.try(:valid?)
                case test
                  when true
                    objects.save
                  when false
                    @errs.push(objects.errors.full_messages)
                  when nil
                    @warns.push('No georeference exists.')
                end
            end
          }
          #@warns.push("warning #{line_counter}")
          #@errs.push("error #{line_counter}") if line_counter.even?
          @warns.flatten!
          @errs.flatten!
          # ap@warns
        end
        line_counter = loop_end(line_counter)
        # break if line_counter > 30
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

# package up the results of the process into a hash
# @param [Integer] current line_counter/rows key
# @return [Integer] new line_counter/rows key
    def loop_end(line_counter)
      @rows[line_counter][:row_objects] = @row_objects
      @rows[line_counter][:err]         = @errs
      @rows[line_counter][:warn]        = @warns
      line_counter + 1
    end

    def dump_hash(objects)
      objects.keys.each {|kee|
        object = objects[kee]
        unless object.blank?
          if object.class.to_s == 'Hash'
            dump_hash(object)
          else
            object.destroy
          end
        end
      }
    end

    def save_hash(objects)
      l_errs = []
      objects.keys.each {|kee|
        object = objects[kee]
        unless object.blank?
          if object.class.to_s == 'Hash'
            l_errs.push(save_hash(object))
          else
            if object.valid?
              object.save
            else
              l_errs.push(object.errors.full_messages)
            end
          end
        end
      }
      l_errs.flatten
    end

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
                                               rank_class: Ranks.lookup(:iczn, :kingdom),
                                               project_id: $project_id)
    end

    def make_ba(row)
      # for each associatedTaxa, find or create an otu, and creata a biological association for it,
      # connecting it to a collection_object
      retval = {}
      bas    = row['associatedtaxa']
      unless bas.blank?
        taxa = bas.split('|')

        taxa.each {|bio_assoc|
          unless bio_assoc.blank?
            br                = BiologicalRelationship.find_or_create_by(name:       'associated_taxa',
                                                                         project_id: @project_id)
            otu               = Otu.find_or_create_by(name:       bio_assoc,
                                                      project_id: @project_id)
            ba                = BiologicalAssociation.new(biological_relationship:             br,
                                                          biological_association_object:       otu,
                                                          biological_association_object_type:  'Otu',
                                                          biological_association_subject_type: 'CollectionObject')
            retval[bio_assoc] = ba
          end
        }
      end
      retval
    end

    def make_ident(row)
      ident  = {}
      cat_no = row['catalognumber'].split(' ')
      unless cat_no.blank?
        if @namespace.short_name != cat_no[0]
          @errs.push("Namespace (#{cat_no[0]}) does not match import namespace (#{@namespace.short_name}).")
        end
        unless cat_no[1].blank?
          id                = Identifier::Local::CatalogNumber.find_or_initialize_by(namespace:  @namespace,
                                                                                     project_id: @project_id,
                                                                                     identifier: cat_no[1])
          ident[:id_cat_no] = id
        end
      end
      occ_id = row['occurrenceid']
      unless occ_id.blank?
        id                = Identifier::Global::OccurrenceId.find_or_initialize_by(relation:   'skos:exactMatch',
                                                                                   project_id: @project_id,
                                                                                   identifier: occ_id)
        ident[:id_occ_id] = id
      end
      ident
    end

# make_prsn:  %w(georeferencedby),
    def make_prsn(row)
      ppl = {}
      # check for person's name
      name = row['georeferencedby']
      unless name.blank?
        if name.downcase.include?('verbatim')
        else
          # make a person to be used as a 'georeferencer'
          parsed    = Person.parser(name)
          pr        = Person.find_or_create_by(last_name:  parsed[0]['family'],
                                               first_name: parsed[0]['given'])
          ppl[:g_r] = pr
        end
      end
      ppl
    end

# available data comes from Tulane geolocation action, reflected by the fact that the georefernce is a GeoLocate
    def make_gr(row)
      geo_by = row['georeferencedby']
      # lat, long           = (lat.length > 0) ? lat : nil, (long.length > 0) ? long : nil
      lat, long = row['decimallatitude'], row['decimallongitude']
      if lat.nil? and long.nil?
        uncert = nil
      else
        uncert = row['coordinateuncertaintyinmeters']
      end
      geo_by = '' if geo_by.nil?
      if geo_by.downcase.include?('verbatim')
        # make a verbatim reference
        # fill in what we can, the real work is done when the collecting_event is added
        g_r = Georeference::VerbatimData.new(error_radius: uncert)
      else
        # faking a Georeference::GeoLocate:
        gl_req_params = {country:   code_to_name(row['countrycode']),
                         state:     row['stateprovince'],
                         county:    row['county'],
                         Placename: row['municipality'],
                         Uncert:    uncert,
                         Latitude:  lat,
                         Longitude: long,
                         locality:  row['locality'],
                         gc:        geo_by}.stringify_keys
        req           = Georeference::GeoLocate::RequestUI.new(gl_req_params)
        #   1) new the Georeference, without a collecting_event
        g_r = Georeference::GeoLocate::GeoLocate.find_or_initialize_by(api_request: req.request_params_string,
                                                                       project_id:  @project_id)
        #   2) save the information from the row in request_hash
        if g_r.new_record?
          g_r.api_request = req.request_params_string
          #   3) build a fake iframe response in the form '52.65|-106.333333|3036|Unavailable'
          text = "#{lat}|#{long}|#{uncert}|Unavailable"
          #   4) use that fake to stimulate the parser to create the object
          g_r.iframe_response = text
        end
      end

      g_r
    end

# @return [Hash] of notes where key is object type
    def make_notes(row)
      ret_val = {}
      begin
        notes      = {}
        geo_remark = row['georeferenceremarks']
        unless geo_remark.blank?
          notes[:remark] = Note.new(text:       geo_remark,
                                    project_id: @project_id)
        end
        ret_val[:g_r] = notes unless notes.blank?
      end

      begin # collecting event notes
        notes      = {}
        loc_remark = row['locationremarks']
        unless loc_remark.blank?
          notes[:remark] = Note.new(text:                  loc_remark,
                                    note_object_attribute: :verbatim_locality,
                                    project_id:            @project_id)
        end
        ret_val[:c_e] = notes unless notes.blank?
      end

      begin # collection object notes
        notes      = {}
        occ_remark = row['occurrenceremarks']
        unless occ_remark.blank?
          notes[:remark] = Note.new(text:       occ_remark,
                                    project_id: @project_id)
        end
        ret_val[:c_o] = notes unless notes.blank?
      end

      ret_val
    end

    def make_tag(row)
      ret_val = {}
      ret_val.merge!(err: [])
      ret_val.merge!(warn: [])

      ret_val
    end

# a full set of symbolized filter names (kees, below) can be found in Utilities::Dates::REGEXP_DATES.keys
    def make_ce(row)
      ret_val     = {}
      kees        = [:yyyy_mm_dd, :mm_dd_yy]
      d_s         = row['eventdate']
      v_l         = [row['municipality'], row['locality']].select {|name| name.present?}.join(':')
      date_params = {}
      unless d_s.blank?
        trials = Utilities::Dates.hunt_dates(d_s, kees)
        trials.keys.each {|kee|
          trial = trials[kee]
          unless trial.blank?
            case kee
              when kees[0]
                type = kee
              when kees[1]
                type = kee
            end
            sdd, sdm, sdy                  = trial[:start_date_day], trial[:start_date_month], trial[:start_date_year]
            edd, edm, edy                  = trial[:end_date_day], trial[:end_date_month], trial[:end_date_year]
            date_params[:start_date_day]   = sdd unless sdd.blank?
            date_params[:start_date_month] = sdm unless sdm.blank?
            date_params[:start_date_year]  = sdy unless sdy.blank?
            date_params[:end_date_day]     = edd unless edd.blank?
            date_params[:end_date_month]   = edm unless edm.blank?
            date_params[:end_date_year]    = edy unless edy.blank?
            break # bail after the first with a date
          end
        }
      end
      g_a_list = [row['county'], row['stateprovince'], code_to_name(row['countrycode'])]
      g_a_text = g_a_list.select {|name| name.present?}.join(':')
      if g_a_text.blank?
        g_a = nil
      else
        g_a_matches = GeographicArea.matching(g_a_text, true)
        g_a         = g_a_matches[g_a_text].try(:first)
      end
      hunt_params   = {project_id:                       @project_id,
                       geographic_area:                  g_a,
                       verbatim_datum:                   row['geodeticdatum'],
                       verbatim_locality:                v_l,
                       verbatim_date:                    d_s,
                       verbatim_label:                   row['locationremarks'],
                       verbatim_geolocation_uncertainty: row['coordinateuncertaintyinmeters'],
                       verbatim_latitude:                row['decimallatitude'],
                       verbatim_longitude:               row['decimallongitude'],
                       verbatim_collectors:              row['recordedby']}.merge!(date_params)
      c_e           = CollectingEvent.find_or_initialize_by(hunt_params)
      ret_val[:c_e] = c_e
      ret_val.merge!(err: [])
      ret_val.merge!(warn: [])

      ret_val
    end

    def make_otu(row)
      Otu.new
    end

# make_co:  %w(individualcount organismquantity organismquantitytype)
# http://rs.gbif.org/vocabulary/gbif/quantity_type_2015-07-10.xml
    def make_co(row)
      ret_val = {}
      warn    = []
      err     = []
      ic      = row['individualcount']
      oq      = row['organismquantity']
      oqt     = row['organismquantitytype']
      combo   = false
      if ic.present? and (oqt.present? or oq.present?)
        # warn.push('Choose either individualCount or the combination of organismQuantity and organismQuantityType, not both.')
        combo = true
      end
      if (ic.to_i > 1) and combo
        # leave ic alone
        warn.push('individualCount has been used instead of the combination of organismQuantity and organismQuantityType.')
      else
        # set ic according to organismQuantityType
        case oqt
          when 'individuals'
            ic = oq.to_i
          when 'percentageOfSpecies',
            'percentageOfBiovolume',
            'percentageOfBiomass',
            'percentageCoverage',
            'dominScale',
            'braunBlanquetScale',
            'biomassAFDG',
            'biomassG',
            'biomassKg',
            'biovolumeCubicMicrons',
            'biovolumeMl'
            ic = oq
          else
            warn.push("Unrecognized organismQuantityType #{oqt}.")
            ic = oq
        end
      end
      # ic will cause the selection of 'lot' or 'specimen'
      c_o = Specimen.new(total: ic)

      ret_val[:c_o] = c_o
      ret_val.merge!(err: err)
      ret_val.merge!(warn: warn)

      ret_val
    end

# make_tn:    %w(scientificname taxonrank family kingdom)
    def make_tn(row)
      ret_val      = {species: nil, genus: nil, tribe: nil}
      this_kingdom = row['kingdom']
      if @kingdom.try(:name) != this_kingdom
        @kingdom = Protonym.find_or_create_by(name:       this_kingdom,
                                              rank_class: Ranks.lookup(:iczn, :kingdom),
                                              project_id: @project_id)

        if @kingdom.new_record?
          @kingdom.parent = @root
          @kingdom.save!
          ret_val[:kingdom] = @kingdom
        end
      end

      this_family = row['family']
      if @family.try(:name) != this_family
        @family = Protonym.find_or_create_by(name:       this_family,
                                             rank_class: Ranks.lookup(:iczn, :family),
                                             project_id: @project_id)
        if @family.new_record?
          @family.parent = @kingdom
          @family.save!
          ret_val[:family] = @family
        end
      end
      sn  = row['scientificname']
      snp = @parser.parse(sn)

      # find or create Protonym based on exact match of row['scientificname'] and taxon_names.cached

      t_n       = Protonym.find_or_create_by(cached: snp[:scientificName][:canonical], project_id: @project_id)
      this_rank = row['taxonrank'].downcase.to_sym

      if t_n.new_record?
        case this_rank
          when :species
            begin # find or create genus
              genus_name = snp[:scientificName][:details][0][:genus][:string]
              @genus     = Protonym.find_or_create_by(name:       genus_name,
                                                      parent:     @family,
                                                      rank_class: Ranks.lookup(:iczn, :genus),
                                                      project_id: @project_id)
              if @genus.new_record?
                @genus.save!
                ret_val[:new_genus] = @genus
              end
            end
            species        = snp[:scientificName][:details][0][:species]
            t_n.parent     = @genus
            t_n.rank_class = Ranks.lookup(:iczn, :species)
            t_n.name       = species[:string]
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
            t_n.rank_class  = Ranks.lookup(:iczn, :genus)
            t_n.name        = genus[:string]
            ret_val[:genus] = t_n
          when :tribe
            tribe           = snp[:scientificName][:details][0][:uninomial]
            t_n.parent      = @family
            t_n.rank_class  = Ranks.lookup(:iczn, :tribe)
            t_n.name        = tribe[:string]
            ret_val[:tribe] = t_n
          else
            raise "Unknown taxonRank #{this_rank}."
        end
        # t_n.create_otu
      else
        ret_val[this_rank] = t_n
      end

      ret_val
    end

# make_td:    %w(scientificname basisofrecord individualcount organismquantity organismquantitytype recordedby)
    def make_td(row)
      TaxonDetermination.new
    end

    def code_to_name(code)
      code.nil? ? nil : GeographicArea.where(iso_3166_a2: code).try(:first).try(:name)
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
# @param [Array] of Strings which represent the TSV file headers
# @param [Hash] of the method names (as keys) for the tasks, with lists of required headers (as values)
# @return [Array] of named tasks to perform, based on the presents of task's word list in the header list
# intersection of the word list from the tasks hash (per key) and the list of headers
    def triage(headers, tasks)
      tasks.select {|kee, vlu| (vlu & headers) == vlu}.keys
    end
  end
end

