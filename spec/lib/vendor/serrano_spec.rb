require 'rails_helper'

describe TaxonWorks::Vendor::Serrano, type: :model, group: [:sources] do

  # needs VCR
  context '#new_from_citation' do
    context 'from citation text' do
      let(:citation) { 'Yoder, M. J., A. A. Valerio, A. Polaszek, L. Masner, and N. F. Johnson. 2009. Revision of Scelio pulchripennis - group species (Hymenoptera, Platygastroidea, Platygastridae). ZooKeys 20:53-118.' }

      specify 'when citation is < 6 characters false is returned' do
        VCR.use_cassette('source_citation_abc') {
          expect(TaxonWorks::Vendor::Serrano.new_from_citation(citation: 'ABC')).to eq(false)
        }
      end

      specify 'when citation is > than 5 characters but unresolvable a Source::Verbatim instance is returned' do
        VCR.use_cassette('source_citation_xyz') {
          expect(TaxonWorks::Vendor::Serrano.new_from_citation(citation: 'ABCDE XYZ').class).to eq(Source::Verbatim)
        }
      end

      specify 'when citation is resolvable a Source::Bibtex instance is returned' do
        VCR.use_cassette('source_citation_polaszek') {
          s = TaxonWorks::Vendor::Serrano.new_from_citation(citation: citation)
          expect(s.class).to eq(Source::Bibtex)
        }
      end
    end

    context 'from DOI text' do
      let(:naked_doi) {'10.11646/zootaxa.4674.4.8'}
      let(:https_doi) {'https://doi.org/' + naked_doi}
      let(:http_doi) {'http://dx.doi.org/' + naked_doi}

      specify 'some stupid string' do
        VCR.use_cassette('source_from_some_stupid_doi') do
          s = TaxonWorks::Vendor::Serrano.new_from_citation(citation: 'Some.stupid/string')
          expect(s.class).to eq(Source::Verbatim)
        end
      end

      specify 'naked_doi 1' do
        VCR.use_cassette('source_from_naked_doi') do
          s = TaxonWorks::Vendor::Serrano.new_from_citation(citation: naked_doi)
          expect(s.class).to eq(Source::Bibtex)
        end
      end

      specify 'naked_doi sets DOI' do
        VCR.use_cassette('source_from_naked_doi') do
          s = TaxonWorks::Vendor::Serrano.new_from_citation(citation: naked_doi)
          expect(s.doi).to eq(naked_doi)
        end
      end

      specify 'https' do
        VCR.use_cassette('source_from_https_doi') do
          s = TaxonWorks::Vendor::Serrano.new_from_citation(citation: https_doi)
          expect(s.class).to eq(Source::Bibtex)
        end
      end

      specify 'http' do
        VCR.use_cassette('source_from_http_doi') do
          s = TaxonWorks::Vendor::Serrano.new_from_citation(citation: http_doi)
          expect(s.class).to eq(Source::Bibtex)
        end
      end

      specify 'remove html tags encoded as $\less$TAG$\greater$ except for <em>/<i>' do
        VCR.use_cassette('source_from_naked_doi') do
          s = TaxonWorks::Vendor::Serrano.new_from_citation(citation: naked_doi)
          expect(s.title).to include('<i>Tachycines</i>')
        end
      end
    end
  end

  context '#cached_string correctly formats ' do
    # Expected result is a resolved citation of Source::Bibtex
    let(:src1) {
      VCR.use_cassette('source_citation_brauer') {
        TaxonWorks::Vendor::Serrano.new_from_citation(citation: 'Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. Smithsonian Institution.')
      }
    }

    # Expected result is a resolved citation of Source::Bibtex
    let(:src2) {
      VCR.use_cassette('source_citation_kevan') {
        TaxonWorks::Vendor::Serrano.new_from_citation(citation: 'Kevan, D.K.M. & Wighton. 1981. Paleocene orthopteroids from south-central Alberta, Canada. Canadian Journal of Earth Sciences. 18(12):1824-1837')
      }
    }

    specify 'text1' do
      expect(src1.cached_string('text')).to eq('Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. G. Fischer, Available from https://doi.org/10.5962%2Fbhl.title.1086')
    end

    specify 'html1' do
      expect(src1.cached_string('html')).to eq(
        'Brauer, A. (1909) <i>Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer.</i> G. Fischer, Available from https://doi.org/10.5962%2Fbhl.title.1086')
    end

    # Hacked Zootaxa format
    # specify 'text2' do
    #   expect(src2.cached_string('text')).to eq('Kevan, D.K.M.E. & Wighton, D.C. (1981) Paleocene orthopteroids from south-central Alberta, Canada. Canadian Journal of Earth Sciences 18(12), 1824–1837.')
    # end

    specify 'text2' do
      expect(src2.cached_string('text')).to start_with(
        'Kevan, D.K.M.E. & Wighton, D.C. (1981) Paleocene orthopteroids from south-central Alberta, Canada.'
      )
    end

    # Hacked Zootaxa format
    # specify 'html2' do
    #   expect(src2.cached_string('html')).to eq('Kevan, D.K.M.E. &amp; Wighton, D.C. (1981) Paleocene orthopteroids from south-central Alberta, Canada. <i>Canadian Journal of Earth Sciences</i> 18(12), 1824–1837.')
    # end

    specify 'html2' do
      expect(src2.cached_string('html')).to start_with(
        'Kevan, D.K.M.E. &amp; Wighton, D.C. (1981) Paleocene orthopteroids from south-central Alberta, Canada.'
      )
    end
  end

end
