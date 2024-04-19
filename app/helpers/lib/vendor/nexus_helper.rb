module Lib::Vendor::NexusHelper
  # !! Some of the code here is run in the context of an ApplicationJob, which
  # doesn't have sessions_current_project_id or sessions_current_user_id -
  # instead assume that Current.project_id and Current.user_id are set.

  def preview_nexus_otus(nexus_file, match_otu_to_name,
    match_otu_to_taxonomy_name)

    taxa_names = nexus_file.taxa.map { |t| t.name }.sort().uniq
    matched_otus = find_matching_otus(taxa_names, match_otu_to_name,
      match_otu_to_taxonomy_name)

    taxa_names.map { |name| matched_otus[name] || name }
  end

  def preview_nexus_descriptors(nexus_file, match_descriptor_to_name)
    descriptor_names = nexus_file.characters.map { |c| c.name }.sort().uniq

    matched_descriptors = {}
    if match_descriptor_to_name
      nexus_file.characters.each { |nxs_chr|
        tw_d = find_matching_descriptor(nxs_chr)[:descriptor]
        if tw_d
          matched_descriptors[nxs_chr.name] = tw_d
        end
      }
    end

    descriptor_names.map { |name| matched_descriptors[name] || name }
  end

  def find_matching_otus(names, match_otus_by_name, match_otus_by_taxon)
    if !match_otus_by_name && !match_otus_by_taxon
      return {}
    end

    matches = {}
    if match_otus_by_taxon
      matches = match_otus_by_taxon(names)
    end

    if match_otus_by_name
      remaining_names = names - matches.keys
      if remaining_names.size
        more_matches = match_otus_by_name(remaining_names)
        matches.merge!(more_matches)
      end
    end

    matches
  end

  # @return [Hash] Returns a hash with descriptor and chr_states
  # properties of the most recently created descriptor with the same name
  # and character states as nxs_char.
  def find_matching_descriptor(nxs_chr)
    descriptors = Descriptor::Qualitative
      .where(project_id: sessions_current_project_id)
      .where(name: nxs_chr.name)
      .order(:name, id: :desc)

    descriptors.each do |tw_d|
      # Require state labels/names from nexus and TW to match.
      # Other operations are conceivable, for instance updating the
      # chr with the new states, but the combinatorics gets very tricky
      # very quickly.

      tw_chr_states = CharacterState
        .where(project_id: sessions_current_project_id)
        .where(descriptor: tw_d)

      if same_state_names_and_labels(nxs_chr.states, tw_chr_states)
        return {
          descriptor: tw_d,
          chr_states: tw_chr_states
        }
      end
    end

    {}
  end

  # @return [Hash] name matched to Otu by taxon name. For those names that
  # match, the Otu returned is the one created most recently.
  def match_otus_by_taxon(names)
    otus = Otu
      .joins(:taxon_name)
      .select('otus.*, taxon_names.cached as tname')
      .where(project_id: Current.project_id)
      .where('taxon_names.cached': names)
      .order('taxon_names.cached', id: :desc)

    otus_to_name_hash(otus, 'tname')
  end

  # @return [Hash] name matched to Otu by otu name. For those names that match,
  # the Otu returned is the one created most recently.
  def match_otus_by_name(names, last_created_only: true)
    otus = Otu
      .where(project_id: Current.project_id)
      .where(name: names)
      .order(:name, id: :desc)

    otus_to_name_hash(otus, 'name')
  end

  # Assumes otus are ordered by name; only returns the first otu if there
  # are repeats for a given name.
  def otus_to_name_hash(otus, name_attr)
    matches = {}
    previous_name = ''
    otus.each { |o|
      name = o[name_attr]
      if name != previous_name
        matches[name] = o
        previous_name = name
      end
    }

    matches
  end

  def same_state_names_and_labels(nex_states, tw_states)
    if nex_states.keys.sort() != tw_states.map{ |s| s.label }.sort()
      return false
    end

    tw_states.each do |s|
      if nex_states[s.label].name != s.name
        return false
      end
    end
    puts Rainbow('Character states matched').orange.bold
    true
  end

  def create_matrix_from_nexus(nexus_doc_id, parsed_nexus, matrix,
    uid, project_id, options)

    Current.user_id = uid
    Current.project_id = project_id
    nf = parsed_nexus
    m = matrix

=begin
      @opt = {
          :title => false,
          :generate_short_chr_name => false,
          :generate_otu_name_with_ds_id => false, # data source, not dataset
          :generate_chr_name_with_ds_id => false,
          :match_otu_to_db_using_name => false,
          :match_otu_to_db_using_matrix_name => false,
          :match_chr_to_db_using_name => false,
          :generate_chr_with_ds_ref_id => false, # data source, not dataset
          :generate_otu_with_ds_ref_id => false,
          :generate_tags_from_notes => false,
          :generate_tag_with_note => false
        }.merge!(options)

      # run some checks on options
      raise if @opt[:generate_otu_name_with_ds_id] && !DataSource.find(@opt[:generate_otu_name_with_ds_id])
      raise if @opt[:generate_chr_name_with_ds_id] && !DataSource.find(@opt[:generate_chr_name_with_ds_id])
      raise if @opt[:generate_chr_with_ds_ref_id] && !Ref.find(@opt[:generate_chr_with_ds_ref_id])
      raise if @opt[:generate_otu_with_ds_ref_id] && !Ref.find(@opt[:generate_otu_with_ds_ref_id])
      raise ':generate_tags_from_notes must be true when including note' if @opt[:generate_tag_with_note] && !@opt[:generate_tags_from_notes]
=end

    new_otus = []
    new_descriptors = []
    new_states = []

    begin
      # TODO: can we narrow the scope of the transaction at all?
      ObservationMatrix.transaction do
        nf = assign_gap_names(nf)

        # Find/create OTUs, add them to the matrix as we do so,
        # and add them to an array for reference during coding.
        taxa_names = nf.taxa.collect{ |t| t.name }.sort().uniq
        matched_otus = find_matching_otus(taxa_names,
          options[:match_otu_to_name], options[:match_otu_to_taxonomy_name])

        nf.taxa.each_with_index do |o, i|
          otu = matched_otus[o.name]
          if !otu
            puts Rainbow("Creating Otu #{o.name}").orange.bold
            otu = Otu.create!(name: o.name)
          else
            puts Rainbow("Found Otu #{o.name}").orange.bold
          end

          new_otus << otu
          ObservationMatrixRow.create!(
            observation_matrix: m, observation_object: otu
          )
        end

        # Find/create descriptors (= nexus characters).
        nf.characters.each_with_index do |nxs_chr, i|
          tw_d = nil
          new_states[i] = {}

          if options[:match_character_to_name]
            r = find_matching_descriptor(nxs_chr)
            tw_d = r[:descriptor]
            if tw_d
              r[:chr_states].each { |twcs|
                new_states[i][twcs.label] = twcs
              }
            end
          end

          if !tw_d
            new_tw_chr_states = []
            nxs_chr.state_labels.each do |nex_state|
              new_tw_chr_states << {
                label: nex_state,
                name: nf.characters[i].states[nex_state].name
              }
              if nf.characters[i].states[nex_state].name == ''
                puts Rainbow(' NO NAME ').orange.bold
              end
            end

            tw_d = Descriptor.create!({
              name: nxs_chr.name,
              type: 'Descriptor::Qualitative',
              character_states_attributes: new_tw_chr_states
            })

            puts Rainbow('Created states').orange.bold
            tw_d.character_states.each do |cs|
              new_states[i][cs.label] = cs
            end
          end

          new_descriptors << tw_d
          ObservationMatrixColumn.create!(
            observation_matrix_id: m.id, descriptor: tw_d
          )
        end

        # Create codings.
        nf.codings[0..nf.taxa.size].each_with_index do |y, i| # y is a rowvector of NexusFile::Coding
          y.each_with_index do |x, j| # x is a NexusFile::Coding
            x.states.each do |z|
              if z != '?'
                # TODO: use find_or_create_by here, and move type to class name
                o = Observation
                  .where(project_id: sessions_current_project_id)
                  .where(type: 'Observation::Qualitative')
                  .find_by(
                    descriptor: new_descriptors[j],
                    observation_object: new_otus[i],
                    character_state: new_states[j][z]
                  )

                if o.nil?
                  Observation.create!(
                    type: Observation::Qualitative,
                    descriptor: new_descriptors[j],
                    observation_object: new_otus[i],
                    character_state: new_states[j][z]
                  )
                end
              end
            end
          end
        end
      end
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { nexus_document_id: nexus_doc_id }
      )
      m.destroy!
      raise
    end
  end

  # Assign a name to all gap states (nexus_parser outputs gap states that have
  # no name, but TW requires a name).
  # @param a nexus file object as returned by nexus_parser
  def assign_gap_names(nf)
    gap_label = nf.vars[:gap]
    if gap_label.nil?
      return nf
    end

    nf.characters.each do |c|
      if c.state_labels.include? gap_label
        c.states[gap_label].name = gap_name_for_states(c.state_labels)
      end
    end
    nf
  end

  def gap_name_for_states(states)
    if !states.include?('gap')
      return 'gap'
    else
      i = 1
      while states.include?("gap_#{i}")
        i = i + 1
      end
      return "gap#{i}"
    end
  end

end