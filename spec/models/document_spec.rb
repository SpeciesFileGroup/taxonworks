require 'rails_helper'

RSpec.describe Document, type: :model, group: :documentation do

  let(:document) { FactoryBot.create(:valid_document) } # a 1 page pdf
  let(:pdf) { Rack::Test::UploadedFile.new( Spec::Support::Utilities::Files.generate_pdf(pages: 10) ) } 

  after(:each) {
    document.destroy
    document.run_callbacks(:commit)
  }

  # Taken verbatim from the doc. 
  context 'default paperclip tests' do
    it { is_expected.to have_attached_file(:document_file) }
    it { is_expected.to validate_attachment_presence(:document_file) }
    it { is_expected.to validate_attachment_content_type(:document_file).
         allowing('application/pdf', 'text/plain', 'text/xml').
         rejecting('image/png') }
    it { is_expected.to validate_attachment_size(:document_file).
         greater_than(1.byte) }
  end


  context 'should manipulate the file system' do
    specify 'creating a document should add it to the filesystem' do
      expect(document.save).to be_truthy
      expect(File.exist?(document.document_file.path)).to be_truthy
    end

    specify 'destroying an image should remove it from the filesystem' do
      path = document.document_file.path
      expect(document.destroy).to be_truthy

      document.run_callbacks(:commit) # NOTE: apparently resolved in Paperclip 
      expect(File.exist?(path)).to be_falsey
    end

    specify 'destroying with a single documentation destroys documentation' do
      a = FactoryBot.create(:valid_documentation, document: document)
      expect(document.destroy).to be_truthy
      expect {a.reload}.to raise_error ActiveRecord::RecordNotFound
    end

    specify 'destroying with > 1 documentation fails' do
      a = FactoryBot.create(:valid_documentation, document: document)
      b = FactoryBot.create(:valid_documentation, document: document)
      document.destroy
      expect(document.destroyed?).to be_falsey 
      expect(a.reload).to be_truthy
      expect(b.reload).to be_truthy
    end

  end

  context 'pages' do

    context 'setting on create()' do
      let!(:d) { Document.create!(
        initialize_start_page: 99,
        document_file: Rack::Test::UploadedFile.new( Rack::Test::UploadedFile.new( pdf, 'application/pdf')) 
      )}

      specify 'page_map is built' do
        expect(d.page_map['1']).to eq('99')
      end
    end

    context 'setting pages on create' do
      before do
        document.initialize_start_page = 5
        document.save
      end

      specify 'updates page_map' do
        expect(document.page_map).to eq({'1' => '5'})
      end
    end

    context 'page metdata' do
      before {document.save }

      specify '#page_total is set' do
        expect(document.page_total).to eq(1)
      end

      specify '#page_map is {}' do
        expect(document.page_map).to eq({})
      end

      context '#set_pages_by_start(page)' do
        context 'one to one' do
          before { document.set_pages_by_start(33) }
          specify '#page_map is updated' do
            expect(document.page_map).to eq({'1' => '33'})
          end
        end
      end

      context '#set_page_map_page(index, page)' do
        specify 'returns false if page does not exist' do
          expect(document.set_page_map_page(99, 1)).to eq(false)
        end

        specify 'returns false if many/many provided' do
          expect(document.set_page_map_page([99], [1])).to eq(false)
        end

        context 'one to one' do
          before { document.set_page_map_page(1, 99) }
          specify 'updates page_map' do
            expect(document.page_map).to eq({'1' => '99'})
          end 
        end

        context 'one to many' do
          before { document.set_page_map_page(1, [99, 'xi']) }
          specify 'updates page_map' do
            expect(document.page_map).to eq({'1' => ['99', 'xi']})
          end 
        end

        context 'many to one' do
          before do
            document.update_attribute(:page_total, 10)  # !! fake page total
            document.set_page_map_page([1,2,3], 1)
          end 

          specify 'updates page_map' do
            expect(document.page_map).to eq({'1' => '1', '2' => '1', '3' => '1'})
          end 
        end
      end

      context '#pdf_page_for' do
        before do
          document.update_attribute(:page_total, 10)  # !! fake page total
          document.set_page_map_page([1,2,3], 1)
          document.set_page_map_page(4, '2')
          document.set_page_map_page('5', 3)
          document.set_page_map_page(7, ['xi', 'xii'])
        end 

        specify '1 to 1' do
          expect(document.pdf_page_for('2')).to contain_exactly('4')
        end

        specify '1 to many' do
          expect(document.pdf_page_for(1)).to contain_exactly('1','2','3')
        end

        specify 'non numerical' do
          expect(document.pdf_page_for('xi')).to contain_exactly('7')
        end
      end 
    end
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
