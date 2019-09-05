require 'rails_helper'

describe Otu, type: :model, group: :otu do

  let(:otu) { Otu.new }

  context 'batch loading' do
    let(:file) {
      f   = File.new('/tmp/temp', 'w+')
      str = CSV.generate do |csv|
        csv << ['Aus']
        csv << ['Bus']
        csv << [nil]
        csv << ['Cus']
      end
      f.write str
      f.rewind
      f
    }

    context '.batch_preview' do
      specify '.batch_preview takes a file argument' do
        expect(Otu.batch_preview(file: file)).to be_truthy
      end

      specify '.batch_preview takes hash of arguments' do
        hsh = {file: file, stuff: :things}
        expect(Otu.batch_preview(hsh)).to be_truthy
      end

      specify '.batch_preview returns an Array' do
        expect(Otu.batch_preview(file: file).class).to eq(Array)
      end

      specify '.batch_preview ignores blank lines' do
        expect(Otu.batch_preview(file: file).count).to eq(3)
      end

      specify '.batch_preview takes the first row as headers' do
        expect(Otu.batch_preview(file: file).count).to eq(3)
      end

      specify 'returns Otus' do
        expect(Otu.batch_preview(file: file).first.class).to eq(Otu)
      end

      specify 'returns Otus with names' do
        expect(Otu.batch_preview(file: file).first.name).to eq('Aus')
      end
    end

    context '.batch_create' do
      let(:params) {
        {otus:
           {'1' => {'name' => 'Aus'},
            '2' => {'name' => 'Bus'}}
        }
      }

      specify 'returns an array' do
        expect(Otu.batch_create(params).class).to eq(Array)
      end

      specify 'returns an array of Otus' do
        expect(Otu.batch_create(params).first.class).to eq(Otu)
      end

      specify 'returns named Otus' do
        expect(Otu.batch_create(params).first.name).to eq('Aus')
      end

      specify 'returns multiple Otus' do
        expect(Otu.batch_create(params).count).to eq(2)
      end
    end
  end
end
