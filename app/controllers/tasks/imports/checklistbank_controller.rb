class Tasks::Imports::ChecklistbankController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def clb_import_taxon(dataset_id, taxon_id, parent_id, nomenclature_code, namespace, prefer_clb_nom_code: false, also_create_otu: false)
    clb_taxon = Colrapi.taxon(dataset_id, taxon_id: taxon_id)
    name = clb_taxon.dig('name', 'scientificName')
    year_of_publication = clb_taxon.dig('name', 'basionymAuthorship', 'year') 
    year_of_publication = clb_taxon.dig('name', 'combinationAuthorship', 'year') if year_of_publication.blank?
    verbatim_authorship = clb_taxon.dig('name', 'authorship')&.gsub(", #{year_of_publication}", "")&.gsub(/[0-9]+/, "")
    extinct = clb_taxon.dig('extinct')
    rank = clb_taxon.dig('name', 'rank')

    # TODO: add citation to CLB dataset to all names/otus?
    # TODO: might need to map rank terms between TW and CLB if the vocab is different at some ranks (e.g., CLB allows zoological accepted variety and forms)
    # TODO: test if special handling is needed on subgenera, infraspecies

    if prefer_clb_nom_code
      case clb_taxon.dig('name', 'code')
      when 'bacterial'
        nomenclature_code = :icnp
      when 'botanical'
        nomenclature_code = :icn
      when 'virus'
        nomenclature_code = :icvcn
      when 'zoological'
        nomenclature_code = :iczn
      end
    end

    name = name.split(' ')[-1]

    puts rank

    p = Protonym.create(
      name: name, 
      rank_class: Ranks.lookup(nomenclature_code.to_sym, rank), 
      verbatim_author: verbatim_authorship,
      year_of_publication: year_of_publication,
      parent_id: parent_id,
      also_create_otu: also_create_otu
    )

    # try removing authorship info if there are errors
    if p.errors.size > 0
      p[:verbatim_author] = nil
      p[:year_of_publication] = nil
      p.save
    end
    
    if extinct
      extinct_predicate = Predicate.create_or_find_by(name: 'Extinct', uri: 'https://api.checklistbank.org/datapackage#Taxon.extinct', definition: 'Catalogue of Life extinct term', project_id: Current.project_id)
      p.otus[0].internal_attribute.create(predicate: extinct_predicate, value: '1')
      p.taxon_name_classifications.create(type: "TaxonNameClassification::#{nomenclature_code.to_s.capitalize}::Fossil")
    end

    p.otus[0]&.identifiers&.create(type: 'Identifier::Local::Import', namespace: namespace, identifier: "clb:#{dataset_id}:#{taxon_id}") if also_create_otu

    p.id
  end

  def clb_import_protonym(name, parent_id, rank, nomenclature_code, verbatim_author=nil, year_of_publication=nil)
    p = Protonym.find_or_create_by(name: name, parent_id: parent_id, rank_class: Ranks.lookup(nomenclature_code.to_sym, rank), verbatim_author: verbatim_author, year_of_publication: year_of_publication, project_id: Current.project_id)
    p.id
  end

  def clb_import_synonyms(dataset_id, taxon_id, tw_taxon_name_id, accepted_parent_id, nomenclature_code, prefer_clb_nom_code: false)
    clb_synonyms = Colrapi.taxon(dataset_id, taxon_id: taxon_id, subresource: 'synonyms')
    homotypic = clb_synonyms['homotypic']
    if clb_synonyms.include? 'homotypic' 
      clb_synonyms['homotypic'].each do |c|

        original_tnr_type = {
          'genus' => 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
          'subgenus' => 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
          'species' => 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
          'subspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
          'variety' => 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
          'form' => 'TaxonNameRelationship::OriginalCombination::OriginalForm',
        }

        parent_id = accepted_parent_id

        query_string = [c['name']['scientificName'], c['name']['authorship']].join(' ')
        parser = TaxonWorks::Vendor::Biodiversity::Result.new(query_string: query_string, code: nomenclature_code.to_sym, match_mode: :ranked, author_match_mode: :strict, project_id: Current.project_id)
        parser.parse
        parser.build_result

        # TODO: works for exact protonym matches only, need to modify biodiversity gem to do stemmed protonym search instead
        if c['name'].include? 'authorship' and (c['name']['authorship'].include? '(' or c['name']['authorship'].include? ')')  # handle subsequent combinations
          combo_ids = {}
          %w[genus subgenus species subspecies variety form].each do |rank|
            unless parser.send(rank).nil?
              if parser.protonym_result[rank.to_sym].size == 1
                combo_ids[rank] = parser.protonym_result[rank.to_sym].first.id
                parent_id = combo_ids[rank]
              elsif parser.protonym_result[rank.to_sym].size > 1
                # TODO: handle multiple matches (or just skip?)
              else
                protonym_name = parser.send(rank)
                combo_ids[rank] = clb_import_protonym(protonym_name, parent_id, rank, nomenclature_code)
                parent_id = combo_ids[rank]
              end
            end
          end

          subseq_combo = Combination.new(name: c['name']['scientificName'].split(' ')[-1], parent_id: tw_taxon_name_id)
          subseq_combo.genus_id = combo_ids['genus']
          subseq_combo.subgenus_id = combo_ids['subgenus']
          subseq_combo.species_id = combo_ids['species']
          subseq_combo.subspecies_id = combo_ids['subspecies']
          subseq_combo.variety_id = combo_ids['variety']
          subseq_combo.form_id = combo_ids['form']
          subseq_combo.save
        else  # handle original combination
          %w[genus subgenus species subspecies variety form].each do |rank|
            unless parser.send(rank).nil?
              if parser.protonym_result[rank.to_sym].size == 1
                TaxonNameRelationship.create(subject_taxon_name_id: parser.protonym_result[rank.to_sym].first.id, object_taxon_name_id: tw_taxon_name_id, type: original_tnr_type[rank])
              elsif parser.protonym_result[rank.to_sym].size > 1
                # TODO: handle multiple matches (or just skip?)
              else
                protonym_name = parser.send(rank)
                p_id = clb_import_protonym(protonym_name, TaxonName.find(parent_id).id, rank, nomenclature_code)
                TaxonNameRelationship.create(subject_taxon_name_id: p_id, object_taxon_name_id: tw_taxon_name_id, type: original_tnr_type[rank])
                parent_id = p_id
              end
            end
          end
        end
      end
    end

    # TODO: handle heterotypic synonyms
    if clb_synonyms.include? 'heterotypic'

      parent_id = tw_taxon_name_id

      case nomenclature_code
        when 'iczn'
          type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective'
        when 'icn'
          type = 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic'
        when 'icnp'
          type = 'TaxonNameRelationship::Icnp::Unaccepting::Synonym::Heterotypic'
        when 'icvcn'
          type = 'TaxonNameRelationship::Icvcn::Unaccepting::Supressed'  # TODO: is this correct? or no synonyms in virus code?
      end

      clb_synonyms['heterotypic'].each do |c|

        query_string = [c['name']['scientificName'], c['name']['authorship']].join(' ')
        parser = TaxonWorks::Vendor::Biodiversity::Result.new(query_string: query_string, code: nomenclature_code.to_sym, match_mode: :ranked, author_match_mode: :strict, project_id: Current.project_id)
        parser.parse
        parser.build_result
        
        # find or create protonym for species, subgenus, genus
        combo_ids = {}
        %w[genus subgenus species subspecies variety form].each do |rank|

          verbatim_author = nil
          year_of_publication = nil
          if parser.finest_rank.to_s == rank
            verbatim_author = parser.result[:parse][:author]
            year_of_publication = parser.year
          end

          unless parser.send(rank).nil?
            if parser.protonym_result[rank.to_sym].size == 1
              combo_ids[rank] = parent_id = parser.protonym_result[rank.to_sym].first.id
            elsif parser.protonym_result[rank.to_sym].size > 1
              # TODO: handle multiple matches (or just skip?)
            else
              protonym_name = parser.send(rank)
              p_id = clb_import_protonym(protonym_name, parent_id, rank, nomenclature_code, verbatim_author, year_of_publication)
              combo_ids[rank] = parent_id = p_id
            end
          end
        end

        combo = Combination.new(name: c['name']['scientificName'].split(' ')[-1], parent_id: accepted_parent_id)
        combo.genus_id = combo_ids['genus']
        combo.subgenus_id = combo_ids['subgenus']
        combo.species_id = combo_ids['species']
        combo.subspecies_id = combo_ids['subspecies']
        combo.variety_id = combo_ids['variety']
        combo.form_id = combo_ids['form']
        combo.save

        # setup taxon name relationship
        TaxonNameRelationship.create(subject_taxon_name_id: combo&.finest_protonym&.id, object_taxon_name_id: tw_taxon_name_id, type: type) unless combo.nil?
      end
    end
  end

  def clb_topdown_importer(dataset_id, taxon_id, parent_id, nomenclature_code, recursive: false, prefer_clb_nom_code: false, also_create_otu: false)
    namespace = Namespace.find_or_create_by(institution: 'ChecklistBank', name: 'ChecklistBank', short_name: 'clb', 
      verbatim_short_name: 'clb', delimiter: ':', is_virtual: true)
    limit = 100

    protonyms = {}
    synonyms = {}
    protonyms[taxon_id] = clb_import_taxon(dataset_id, taxon_id, parent_id, nomenclature_code, namespace, prefer_clb_nom_code: prefer_clb_nom_code, also_create_otu: also_create_otu)
    if recursive
      offset = 0
      resp = Colrapi.tree(dataset_id, taxon_id: taxon_id, children: true, limit: limit, offset: offset)
      total = resp['total']
      taxa = resp['result']
      until taxa.size >= total
        offset += limit
        taxa += Colrapi.tree(dataset_id, taxon_id: taxon_id, children: true, limit: limit, offset: offset)['result']
      end

      # recurse through tree to get all taxa
      queue = taxa.clone
      until queue.empty?
        c = queue.pop
        if c['childCount'] > 0
          offset = 0
          resp = Colrapi.tree(dataset_id, taxon_id: c['id'], children: true, limit: limit, offset: offset)
          total = resp['total']
          children = resp['result']
          until children.size >= total
            offset += limit
            children += Colrapi.tree(dataset_id, taxon_id: c['id'], children: true, limit: limit, offset: offset)['result']
          end
          children.each do |c|
            queue.append(c)
          end
          taxa += children
        end
      end

      taxa.each do |c|
        unless %w[unranked form variety].include? c['rank']  # skip importing unranked taxa; TODO: give option to also exclude other ranks in the form?
          protonyms[c['id']] = clb_import_taxon(dataset_id, c['id'], protonyms[c['parentId']], nomenclature_code, namespace, prefer_clb_nom_code: prefer_clb_nom_code, also_create_otu: also_create_otu) 
        end
      end

      taxa.each do |c|
        synonyms[c['id']] = clb_import_synonyms(dataset_id, c['id'], protonyms[c['id']], protonyms[c['parentId']], nomenclature_code, prefer_clb_nom_code: prefer_clb_nom_code)
      end

      protonyms[taxon_id]
    end
  end

  def import 
    parent_id = params.require(:taxon_name)[:parent_id]
    dataset_id = params.require(:dataset_id)
    taxon_id = params.require(:taxon_id)
    nomenclature_code = params.require(:nomenclature_code)
    recursive = params.require(:recursive).to_s == "true"
    prefer_clb_nom_code = params.require(:prefer_clb_nom_code).to_s == "true"
    also_create_otu = params.require(:also_create_otu).to_s == "true"
    tw_parent_id = clb_topdown_importer(dataset_id, taxon_id, parent_id, nomenclature_code, recursive: recursive, prefer_clb_nom_code: prefer_clb_nom_code, also_create_otu: also_create_otu)
    redirect_to browse_nomenclature_task_path(taxon_name_id: tw_parent_id)
  end

end
