require 'rails_helper'

describe Utilities::Nomenclature do

  let(:n) { Utilities::Nomenclature }

  context '.unmisspell_name' do
    specify 'removes [sic]' do
      expect(n.unmisspell_name('Zoraida (Zoraida) sinuata [sic]'))
        .to eq('Zoraida (Zoraida) sinuata')
    end

    specify 'removes (sic)' do
      expect(n.unmisspell_name('Aus bus (sic)')).to eq('Aus bus')
    end

    specify 'leaves a name without sic alone' do
      expect(n.unmisspell_name('Aus bus')).to eq('Aus bus')
    end
  end

end
