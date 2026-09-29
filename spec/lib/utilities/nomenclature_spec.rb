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

  context '.without_infrageneric_epithet' do
    specify 'removes a parenthetical subgenus from a species' do
      expect(n.without_infrageneric_epithet('Aedes (Stegomyia) aegypti'))
        .to eq('Aedes aegypti')
    end

    specify 'removes a parenthetical subgenus from a subspecies' do
      expect(
        n.without_infrageneric_epithet('Carabus (Megodontus) violaceus violaceus')
      ).to eq('Carabus violaceus violaceus')
    end

    specify 'leaves a name without a subgenus alone' do
      expect(n.without_infrageneric_epithet('Bombus terrestris'))
        .to eq('Bombus terrestris')
    end

    specify 'leaves ICN infraspecific connecting terms alone' do
      expect(n.without_infrageneric_epithet('Olea europaea subsp. africana'))
        .to eq('Olea europaea subsp. africana')
    end

    specify 'nil is nil' do
      expect(n.without_infrageneric_epithet(nil)).to be_nil
    end
  end

  context '.infrageneric_epithet' do
    specify 'extracts the epithet from a "Genus (Subgenus)" combination' do
      expect(n.infrageneric_epithet('Aedes (Stegomyia)')).to eq('Stegomyia')
    end

    specify 'returns a bare epithet as is' do
      expect(n.infrageneric_epithet('Stegomyia')).to eq('Stegomyia')
    end

    specify 'nil is nil' do
      expect(n.infrageneric_epithet(nil)).to be_nil
    end
  end

end
