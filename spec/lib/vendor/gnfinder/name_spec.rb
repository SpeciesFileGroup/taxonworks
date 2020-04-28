require 'rails_helper'

describe Vendor::Gnfinder::Name, type: [:model]  do
  let(:monomial) { <<~UNINOMIAL
                   {
                     "type": "Uninomial",
                     "verbatim": "DIAPRIINAE",
                     "name": "Diapriinae",
                     "odds": 7893.583631673039,
                     "odds_details": {
                       "Name": {
                         "PriorOdds": {
                           "true": 0.1
                         },
                         "uniLen": {
                           "10": 3.1988876638791726
                         },
                         "uniDict": {
                           "WhiteUninomial": 668.2256749411124
                         },
                         "abbr": {
                           "false": 0.8679430877999654
                         },
                         "uniEnd3": {
                           "nae": 42.54620402246783
                         }
                       }
                     },
                     "start": 14,
                     "end": 24,
                     "annotation": "",
                     "words_before": [
                       "The",
                       "Genera",
                       "Of"
                     ],
                     "words_after": [
                       "Hymenoptera",
                       "Diapriidae",
                       "In"
                     ],
                     "verification": {
                       "BestResult": {
                         "dataSourceId": 2,
                         "dataSourceTitle": "Wikispecies",
                         "taxonId": "217950",
                         "matchedName": "Diapriinae",
                         "matchedCanonical": "Diapriinae",
                         "currentName": "Diapriinae",
                         "matchType": "ExactMatch"
                       },
                       "dataSourcesNum": 8,
                       "dataSourceQuality": "HasCuratedSources",
                       "retries": 1
                     }
                   }
                   UNINOMIAL
  }

  let(:binomial) { <<~BINOMIAL
                   {
                     "type": "Binomial",
                     "verbatim": "Turripria woldai",
                     "name": "Turripria woldai",
                     "odds": 6777191921.722317,
                     "odds_details": {
                       "Name": {
                         "abbr": {
                           "false": 0.8679430877999654
                         },
                         "uniEnd3": {
                           "ria": 18.35326448028024
                         },
                         "spEnd3": {
                           "dai": 7.508153651023735
                         },
                         "spLen": {
                           "6": 2.296153847821055
                         },
                         "spDict": {
                           "WhiteSpecies": 5628.6125203841275
                         },
                         "PriorOdds": {
                           "true": 0.1
                         },
                         "uniLen": {
                           "9": 2.171091427809083
                         },
                         "uniDict": {
                           "WhiteGenus": 20194.430603370172
                         }
                       }
                     },
                     "start": 7024,
                     "end": 7040,
                     "annotation": "",
                     "words_before": [
                       "�",
                       "Costa",
                       "Rica"
                     ],
                     "words_after": [
                       "�",
                       "Panama",
                       "New"
                     ],
                     "verification": {
                       "BestResult": {
                         "dataSourceId": 169,
                         "dataSourceTitle": "uBio NameBank",
                         "taxonId": "102386146",
                         "matchedName": "Turripria woldai Masner \u0026 Garcia",
                         "matchedCanonical": "Turripria woldai",
                         "currentName": "Turripria woldai Masner \u0026 Garcia",
                         "classificationPath": "|Turripria woldai",
                         "classificationRank": "kingdom|",
                         "matchType": "ExactCanonicalMatch"
                       },
                       "dataSourcesNum": 2,
                       "dataSourceQuality": "Unknown",
                       "retries": 1
                     }
                   } 
                   BINOMIAL
  }

  let(:monomial_json) { JSON.parse(monomial, symbolize_names: true) }

  let(:binomial_json) { JSON.parse(binomial, symbolize_names: true) }

  let(:mn) { Vendor::Gnfinder::Name.new(monomial_json) }
  let(:bn) { Vendor::Gnfinder::Name.new(binomial_json) }

  specify '#name' do
    expect(mn.name).to eq('Diapriinae')
  end

  specify '#verbatim' do
    expect(mn.verbatim).to eq('DIAPRIINAE')
  end

  specify '#match_start' do
    expect(mn.match_start).to eq(14)  # was 21
  end

  specify '#match_end' do
    expect(mn.match_end).to eq(24) # was 31
  end

  # PENDING
  specify '#words_before' do
    expect(mn.words_before).to contain_exactly("Genera", "Of", "The")
  end

  specify '#words_after' do
    expect(mn.words_after).to contain_exactly("Diapriidae", "Hymenoptera", "In")
  end

  # No more path in wikispecies
  # specify '#classification_path' do
  #  expect(mn.classification_path).to include("Basal", "Bilateria", "Boltonocostidae", "Carbotriplurida", "Cephalornis")
  # end

  specify '#data_source_title' do
    expect(mn.data_source_title).to eq('Wikispecies')
  end

  specify '#classification_rank' do
    expect(mn.classification_rank).to contain_exactly()
  end

  specify '#protonym_name 1' do
    expect(mn.protonym_name).to eq('Diapriinae')
  end

  specify '#protonym_name 1' do
    expect(bn.protonym_name).to eq('woldai')
  end

  specify '#protonym_name 1' do
    expect(bn.matches).to contain_exactly()
  end

  specify '#is_verified?' do
    expect(bn.is_verified?).to eq(true)
  end

  specify '#is_in_taxonworks?' do
    expect(bn.is_in_taxonworks?).to eq(false)
  end

end
