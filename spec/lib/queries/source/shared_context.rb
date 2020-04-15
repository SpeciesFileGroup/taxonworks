shared_context 'source queries' do 
  let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }
  let(:p2) { FactoryBot.create(:valid_person, last_name: 'Jones') }
  let(:p3) { FactoryBot.create(:valid_person, last_name: 'Brandt', prefix: 'von') }

  let(:j1) { FactoryBot.create(:valid_serial, name: 'Journal of Stuff and Things') }
  let!(:a1) { AlternateValue::Abbreviation.create!(value: 'J. S. and T.', alternate_value_object: j1, alternate_value_object_attribute: :name) }

  let!(:s1) { Source::Verbatim.create!(
    verbatim: 'Grumwald, 1981. Things I Mumble. J. Unintelligible Speach. 22: 1-19') 
  } 

  let!(:s2) { Source::Bibtex.create!(
    bibtex_type: :article,
    authors: [p1], 
    year: 1920, 
    title: 'Bad cops, good cops, rubocops.'
  )}

  let!(:s3) { Source::Bibtex.create!(
    bibtex_type: :article,
    author: 'Smith', 
    year: 1921,
    year_suffix: 'a',
    title: 'Bad cops, good caps, rubycoats.'
  )}

  let!(:s4) { Source::Bibtex.create!(
    bibtex_type: :article,
    authors: [p2, p3, p1], 
    year: 1924, 
    title: 'We all got together and wrote about Things!'
  )}

  let!(:s5) { Source::Bibtex.create!(
    bibtex_type: :article,
    author: 'von Brandt & Bartholemew', 
    year: 1940, 
    title: 'Creatures from the Black Lagoon.',
    serial: j1
  )}

  let!(:s6) { Source::Verbatim.create!(verbatim: 'foo' )  }
  
  let!(:all_source_ids) { [s1.id, s2.id, s3.id, s4.id, s5.id, s6.id] }
end
