module Lib::Vendor::NexusHelper
  # !! Some of the code here is run in the context of an ApplicationJob, which
  # doesn't have sessions_current_project_id or sessions_current_user_id -
  # instead assume that Current.project_id and Current.user_id are set by the
  # caller.

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
      .where(project_id: Current.project_id)
      .where(name: nxs_chr.name)
      .order(:name, id: :desc)

    descriptors.each do |tw_d|
      # Require state labels/names from nexus and TW to match.
      # Other operations are conceivable, for instance updating the
      # chr with the new states, but the combinatorics gets very tricky
      # very quickly.

      tw_chr_states = CharacterState
        .where(project_id: Current.project_id)
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

    true
  end

  def create_citation_for(citation, model, id)
    Citation.create!(citation.merge({
      citation_object_type: model,
      citation_object_id: id
    }))
  end

  def populate_matrix_with_nexus(nexus_doc_id, parsed_nexus, matrix, options)
    start_t = Time.now
    nf = parsed_nexus
    m = matrix

    new_otus = []
    new_descriptors = []
    new_states = []

    begin
      if options[:cite_matrix]
        create_citation_for(options[:citation], 'ObservationMatrix', m.id)
      end

      # Find/create OTUs, add them to the matrix as we do so,
      # and add them to an array for reference during coding.
      taxa_names = nf.taxa.collect{ |t| t.name }.sort().uniq
      matched_otus = find_matching_otus(taxa_names,
        options[:match_otu_to_name], options[:match_otu_to_taxonomy_name])

      ObservationMatrix.transaction do
        puts 'Creating otus'
        t = Time.now
        nf.taxa.each_with_index do |o, i|
          otu = matched_otus[o.name]
          if !otu
            otu = Otu.create!(name: o.name)
            if options[:cite_otus]
              create_citation_for(options[:citation], 'Otu', otu.id)
            end
          end

          new_otus << otu
          ObservationMatrixRow.create!(
            observation_matrix: m, observation_object: otu
          )
        end
        puts 'Finished creating otus ' + (Time.now - t).to_s

        puts 'Creating descriptors'
        t = Time.now
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
            end

            tw_d = Descriptor::Qualitative.create!(name: nxs_chr.name)
            new_tw_chr_states.each { |cs|
              CharacterState.create!(cs.merge({ descriptor: tw_d }))
            }
            if options[:cite_descriptors]
              create_citation_for(options[:citation], 'Descriptor', tw_d.id)
            end

            tw_d.character_states.each do |cs|
              new_states[i][cs.label] = cs
            end
          end

          new_descriptors << tw_d
          ObservationMatrixColumn.create!(
            observation_matrix_id: m.id, descriptor: tw_d
          )
        end
        puts 'Finished creating descriptors ' + (Time.now - t).to_s

        puts 'Creating codings'
        t = Time.now
        # Create codings.
        nf.codings[0..nf.taxa.size].each_with_index do |y, i| # y is a rowvector of NexusFile::Coding
          y.each_with_index do |x, j| # x is a NexusFile::Coding
            x.states.each do |z|
              if z != '?'
                o = Observation::Qualitative
                  .where(project_id: Current.project_id)
                  .find_by(
                    descriptor: new_descriptors[j],
                    observation_object: new_otus[i],
                    character_state: new_states[j][z]
                  )
                # TODO: is it a sign that something's wrong if this observation
                # already exists? i.e. that we may also be adding observations to
                # a different matrix in that case?
                if o.nil?
                  o = Observation::Qualitative.create!(
                    descriptor: new_descriptors[j],
                    observation_object: new_otus[i],
                    character_state: new_states[j][z]
                  )
                  if options[:cite_observations]
                    create_citation_for(options[:citation], 'Observation', o.id)
                  end
                end
              end
            end
          end
        end
        puts 'Finished creating codings ' + (Time.now - t).to_s
        puts 'Total run time ' + (Time.now - start_t).to_s
      end
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: {
          nexus_document_id: nexus_doc_id,
          matrix_id: matrix.id,
          user_id: Current.user_id,
          project_id: Current.project_id
        }
        .merge(options)
      )
      m.destroy!
      raise
    end
  end

end