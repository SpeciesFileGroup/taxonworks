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
                     "start": 21,
                     "end": 31,
                     "annotation": "",
                     "words_before": [
                       "The",
                       "Genera",
                       "Of"
                     ],
                     "words_after": [
                       "Hymenoptera",
                       "Diapriidae",
                       "In",
                       "The"
                     ],
                     "verification": {
                       "BestResult": {
                         "dataSourceId": 2,
                         "dataSourceTitle": "Wikispecies",
                         "taxonId": "217950",
                         "matchedName": "Diapriinae",
                         "matchedCanonical": "Diapriinae",
                         "currentName": "Diapriinae",
                         "classificationPath": "Cephalornis|Coelenterata|Bilateria|Nephrozoa|Protostomia|Ecdysozoa|Circumscriptional names of the taxon under|Notchia|Carbotriplurida|Boltonocostidae|Circumscriptional names|Pterygota|Circumscriptional name|Basal|Eumetabola|Strashila incredibilis|Hymenopterida|Kulbastavia|Tiphiinae|Mesoserphidae|Diapriidae|Diapriinae",
                         "classificationRank": "|||||||||||||||||||||",
                         "classificationIDs": "80|4404|192967|249913|99137|148590|249529|425|11905|11903|151866|11899|277474|79348|277614|66325|227790|11898|11906|124505|217951|217950",
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
                         "spDict": {
                           "WhiteSpecies": 5628.6125203841275
                         },
                         "spEnd3": {
                           "dai": 7.508153651023735
                         },
                         "PriorOdds": {
                           "true": 0.1
                         },
                         "uniLen": {
                           "9": 2.171091427809083
                         },
                         "uniDict": {
                           "WhiteGenus": 20194.430603370172
                         },
                         "abbr": {
                           "false": 0.8679430877999654
                         },
                         "uniEnd3": {
                           "ria": 18.35326448028024
                         },
                         "spLen": {
                           "6": 2.296153847821055
                         }
                       }
                     },
                     "start": 8652,
                     "end": 8668,
                     "annotation": "",
                     "words_before": [
                       "hoguei",
                       "�",
                       "Costa",
                       "Rica"
                     ],
                     "words_after": [
                       "�",
                       "Panama",
                       "New",
                       "generic"
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
  let(:mn) { Vendor::Gnfinder::Name.new(monomial_json) }

  specify '#name' do
    expect(mn.name).to eq('Diapriinae') 
  end

  specify '#verbatim' do
    expect(mn.verbatim).to eq('DIAPRIINAE') 
  end

  specify '#match_start' do
    expect(mn.match_start).to eq(21) 
  end

  specify '#match_end' do
    expect(mn.match_end).to eq(31) 
  end

  specify '#words_before' do
    expect(mn.words_before).to contain_exactly("Genera", "Of", "The") 
  end

  specify '#words_after' do
    expect(mn.words_after).to contain_exactly("Diapriidae", "Hymenoptera", "In", "The")
  end

  specify '#classification_path' do
    expect(mn.classification_path).to include("Basal", "Bilateria", "Boltonocostidae", "Carbotriplurida", "Cephalornis")
  end

  specify '#classification_rank' do
    expect(mn.classification_rank).to contain_exactly()
  end

  specify '#data_source_title' do
    expect(mn.data_source_title).to eq('Wikispecies')
  end

end
