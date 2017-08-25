require 'rails_helper'

describe 'Utilities::Logic' do

  specify '#parse_logic' do
    expect(Utilities::Logic.parse_logic('(a+b).(c+d)')).to eq('ac+ad+bc+bd')
  end
 
  specify '#or_queries 1' do
    expect(Utilities::Logic.or_queries('(a+b).(c+d)')).to eq(%w{ac ad bc bd})
  end

  specify '#or_queries 2' do
    expect(Utilities::Logic.or_queries('A.(B+C)')).to contain_exactly('AB', 'AC')
  end

end
