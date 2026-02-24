# Methods that do nomenclatural operations on Strings. Should not require any reference to any software.
module Utilities::Nomenclature

  # expands year into author if parens
  # @param name - the name
  # @param author, with our without parens
  # @param year, 4 digit year
  def self.preview_name(name, author, year)
    a = if author =~ /\(/ && year
      author.split(')').first.strip + ", #{year})"
    elsif year
      [author, year].compact.join(', ')
    end

   [name, a].compact.join(' ')
  end

  def self.reified_id(id, name)
    id.to_s + '-' + Digest::MD5.hexdigest(name)
  end

  def self.predict_three_forms(name)
    exception = LATIN_ADJECTIVES[name]

    return exception unless exception.nil?
    m_name, f_name, n_name = nil, nil, nil
    case name
    when /(color|coloris)$/
      m_name, f_name, n_name = name, name, name
    when /is$/
      m_name, f_name, n_name = name, name, name[0..-3] + 'e'
    when /e$/
      m_name, f_name, n_name = name[0..-2] + 'is', name[0..-2] + 'is', name
    when /us$/
      m_name, f_name, n_name = name, name[0..-3] + 'a', name[0..-3] + 'um'
    when /(niger|integer)$/
      m_name, f_name, n_name = name, name[0..-3] + 'ra', name[0..-3] + 'rum'
    when /(fer|ger)$/
      m_name, f_name, n_name = name, name + 'a', name + 'um'
    when /er$/
      m_name, f_name, n_name = name, name[0..-3] + 'ra', name[0..-3] + 'rum'
    when /(ferum|gerum)$/
      m_name, f_name, n_name = name[0..-3], name[0..-3] + 'a', name
    when /(gera|fera)$/
      m_name, f_name, n_name = name[0..-2], name, name[0..-2] + 'um'
    when /(brum|frum|grum)$/
      m_name, f_name, n_name = name[0..-4] + 'er', name[0..-3] + 'a', name
    when /(bra|gra|fra)$/
      m_name, f_name, n_name = name[0..-3] + 'er', name, name[0..-2] + 'um'
    when /(um)$/
      m_name, f_name, n_name = name[0..-3] + 'us', name[0..-3] + 'a', name
    when /a$/
      m_name, f_name, n_name = name[0..-2] + 'us', name, name[0..-2] + 'um'
    when /(nor|ior|jor)$/
      m_name, f_name, n_name = name, name, name[0..-3] + 'us'
    else
      m_name, f_name, n_name = name, name, name
    end
    {masculine_name: m_name, feminine_name: f_name, neuter_name: n_name}
  end


  # @return Array [name, rank]
  #   summarizes multinomials into a single
  #   target infraspecies monomial, and its rank
  # name_hash returs rank: [qualifier,name], we are ignoring qualifier here on purpose
  def self.infraspecies(name_hash)
    ['subform', 'form', 'subvariety', 'variety', 'subspecies'].each do |r|
      if name_hash[r]
        return [name_hash[r].last, r]
      end
    end
    [nil, nil]
  end

  # @return [String, nil]
  #   returns nil for Higher names where Higher names is TODO
  def self.full_name(name_hash, rank: nil, non_binomial: false)
    d = name_hash

    elements = []

    elements.push(d['genus']) unless (non_binomial && d['genus'][1] == '[GENUS NOT SPECIFIED]')

    elements.push ['(', d['subgenus'], ')']
    elements.push ['(', d['infragenus'], ')'] if rank == 'infragenus'
    elements.push ['(', d['supergenus'], ')'] if rank == 'supergenus'
    elements.push ['(', d['supersubgenus'], ')'] if rank == 'supersubgenus'
    elements.push ['(', d['supersupersubgenus'], ')'] if rank == 'supersupersubgenus'

    elements.push [d['supersuperspecies']] if rank == 'supersuperspecies'
    elements.push [d['superspecies']] if rank == 'superspecies'
    elements.push [d['subsuperspecies']] if rank == 'subsuperspecies'

    elements.push(d['species'], d['subspecies'], d['variety'], d['subvariety'], d['form'], d['subform'])

    # TODO - revisit the need for this.
    elements = elements.flatten.compact.join(' ').gsub(/\(\s*\)/, '').gsub(/\(\s/, '(').gsub(/\s\)/, ')').squish
    elements.presence
  end

  # Protonym::Format still retains a version of this.
  # Given a taxon name, italicize and format based on a number of attributes
  def self.htmlize(undecorated_name, italicized: false, hybrid: false, fossil: false, candidatus: false)
    return nil if undecorated_name.nil?
    n = undecorated_name

    return  "\"<i>Candidatus</i> #{n}\"" if candidatus
    if hybrid
      w = n.split(' ')
      w[-1] = ('×' + w[-1]).gsub('×(', '(×')
      n = w.join(' ')
    end

    m = n
    m = Utilities::Italicize.taxon_name(n) if italicized
    m = '† ' + m if fossil
    m
  end

  # SIC_PATTERN = /\s*[\[\(]\s*sic\s*[\]\)]/

  # TODO: Untested
  def self.unmisspell_name(misspelled_name)
    misspelled_name.gsub(/\s*[\[\(]\s*sic\s*[\]\)]/, '').strip
  end

end
