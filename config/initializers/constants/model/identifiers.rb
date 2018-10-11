# Be sure to restart your server (or console) when you modify this file.

require_dependency Rails.root.to_s + '/app/models/identifier.rb'

IDENTIFIERS_JSON = {
  global: {
    all: Identifier::Global.descendants.inject({}){|hsh, a| hsh.merge!( a.name => { label: a.name.demodulize.underscore.humanize.downcase} )},
    common: [  
      'Identifier::Global::Doi',
      'Identifier::Global::Orcid',
      'Identifier::Global::Lsid' 
    ]
  }, 
  local: {
    all: Identifier::Local.descendants.inject({}){|hsh, a| hsh.merge!( a.name => { label: a.name.demodulize.underscore.humanize.downcase} )},
    common: [ 
      'Identifier::Local::CatalogNumber',
      'Identifier::Local::TripCode' 
    ]
  },
  unknown: {
    all: {'Identifier::Unknown' => {label: 'unknown'}},
    common: ['Identifier::Unknown']
  } 
}.freeze

