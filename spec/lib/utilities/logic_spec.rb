require 'rails_helper'

describe 'Logic', group: [:dna] do

  specify '#parse_logic' do
    expect(Utilities::Logic.parse_logic('(a+b).(c+d)')).to eq('ac+ad+bc+bd')
  end
  
end
