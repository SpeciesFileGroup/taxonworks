# Methods that do nomenclatural operations on Strings. Should not require any reference to any software.
module Utilities::Nomenclature

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

    elements = elements.flatten.compact.join(' ').gsub(/\(\s*\)/, '').gsub(/\(\s/, '(').gsub(/\s\)/, ')').squish
    elements.presence
  end

  # Protonym::Format still retains a version of this.
  # Given a taxon name, italicize and format based on a number of flags
  def self.htmlize(name, italicized: false, hybrid: false, fossil: false, candidatus: false)
    return nil if name.nil?

    return  "\"<i>Candidatus</i> #{name}\"" if candidatus
    if hybrid
      w = name.split(' ')
      w[-1] = ('×' + w[-1]).gsub('×(', '(×')
      name = w.join(' ')
    end

    m = name
    m = Utilities::Italicize.taxon_name(name) if italicized
    m = '† ' + m if fossil
    m
  end

end
