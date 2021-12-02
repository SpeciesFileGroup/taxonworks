require 'rails_helper'
# TODO: Uses of contain_exactly here might not produce intended behaviour as this matcher doesn't care about order.
describe Vendor::Gnfinder::Name, type: [:model]  do

  let(:finder) { Vendor::Gnfinder.finder }

  let(:monominal_string) { 'The ACRIDIDAE of the World' }
  let(:binominal_string) { 'Turripria woldai sp. nov. is the same as Turripria woldaii' }

  let(:gnfinder_monominal) { finder.find_names(monominal_string, verification: true, words_around: 3).names.first }
  let(:gnfinder_binominal) { finder.find_names(binominal_string, verification: true, words_around: 3).names.first }

  let(:mn) { ::Vendor::Gnfinder::Name.new(gnfinder_monominal) }
  let(:bn) { ::Vendor::Gnfinder::Name.new(gnfinder_binominal) }

  specify '#project_id' do
    expect(mn.project_id).to eq([])
  end

  context '#found 1' do

    let(:n) { mn.found }

    specify '#name' do
      expect(n.name).to eq('Acrididae')
    end

    specify '#verbatim' do
      expect(n.verbatim).to eq('ACRIDIDAE')
    end

    specify '#words_start' do
      expect(n.start).to eq(4)
    end

    specify '#words_end' do
      expect(n.end).to eq(13)
    end

    specify '#words_before' do
      expect(n.words_before).to contain_exactly("The")
    end

    specify '#words_after' do
      expect(n.words_after).to contain_exactly("of", "the", "World")
    end
  end

  specify '#classification_path' do
    expect(mn.classification_path).to contain_exactly(
      'Biota', 'Animalia', 'Arthropoda', 'Insecta', 'Orthoptera', 'Caelifera', 'Acrididea', 'Acridomorpha', 'Acridoidea', 'Acrididae'
    )
  end

  specify '#classification_rank' do
    expect(mn.classification_rank).to contain_exactly(
      'unranked', 'kingdom', 'phylum', 'class', 'order', 'suborder', 'infraorder', 'nanorder', 'superfamily', 'family'
    )
  end

  specify '#data_source_title_short' do
    expect(mn.best_result.data_source_title_short).to eq('Catalogue of Life')
  end

  specify '#protonym_name 1' do
    expect(mn.protonym_name).to eq('Acrididae')
  end

  specify '#protonym_name 2' do
    expect(bn.protonym_name).to eq('woldai')
  end

  specify '#is_verified?' do
    expect(bn.is_verified?).to eq(true)
  end

  specify '#is_in_taxonworks?' do
    expect(bn.is_in_taxonworks?).to eq(false)
  end

  specify '#taxonworks_parent_name' do
    expect(bn.taxonworks_parent_name).to eq('Turripria')
  end

  specify '#taxonworks_parent' do
    expect(bn.taxonworks_parent).to eq(nil)
  end

  specify '#is_new_name?' do
    expect(bn.is_new_name?).to eq(true)
  end

end
