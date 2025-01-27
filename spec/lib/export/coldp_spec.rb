require 'rails_helper'
require 'export/coldp'

describe Export::Coldp, type: :model, group: :col do
  include ActiveJob::TestHelper

  specify 'otus' do
    p = FactoryBot.create(:valid_protonym)
    o = Otu.create!(taxon_name: p)
    expect(::Export::Coldp.otus(o.id).count).to eq(1)
  end 

  context 'download packaging' do
    before { include ActiveJob::TestHelper }

    let!(:species) { FactoryBot.create(:iczn_species) }
    let(:otu) { Otu.create(taxon_name: species) }

    let!(:d) { 
      ::Export::Coldp.download_async(
        otu, 'https://example.org/some_url',
        prefer_unlabelled_otus: true 
      )   
    } 

    specify '#download_async creates Download' do 
      expect(Download.count).to eq(1)
    end

    specify '#download_async creates Zip after worker' do 
      perform_enqueued_jobs
      expect(File.exist?(d.file_path)).to be_truthy
    end

    context 'when performed' do
      before { perform_enqueued_jobs } 

      ::Export::Coldp::FILETYPES.each do |t|

        specify "includes #{t}.tsv" do
          z = Zip::File.open(Download.first.file_path)
          expect(z.find_entry("#{t}.tsv")).to be_truthy
        end
      end
    end

  end
end
