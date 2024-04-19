module Lib::Vendor::NexusHelper
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
      .where(project_id: sessions_current_project_id)
      .where('taxon_names.cached': names)
      .order('taxon_names.cached', id: :desc)

    otus_to_name_hash(otus, 'tname')
  end

  # @return [Hash] name matched to Otu by otu name. For those names that match,
  # the Otu returned is the one created most recently.
  def match_otus_by_name(names, last_created_only: true)
    otus = Otu
      .where(project_id: sessions_current_project_id)
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

end