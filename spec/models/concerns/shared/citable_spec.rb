require 'rails_helper'

describe 'Citable', type: :model, group: [:nomenclature] do
  let(:class_with_citations) { TestCitable.new } 
  let(:citation) { FactoryGirl.build(:citation, source: source) }

  let!(:source) { FactoryGirl.create(:valid_source_bibtex, year: 1905) }

  context 'creation' do
    specify 'with #new, base must be saved' do
      class_with_citations.save!
      class_with_citations.citations << Citation.new(source: source)
      expect(class_with_citations.save!).to be_truthy
      expect(class_with_citations.citations(true).count).to eq(1)
    end
  end

  context 'associations' do
    context 'has_many' do
      specify '#citations - includes creating a citation' do
        expect(class_with_citations).to respond_to(:citations) # tests that the method citations exists
        expect(class_with_citations.citations.to_a).to eq([]) # there are no citations yet.

        expect(class_with_citations.citations << citation).to be_truthy
        expect(class_with_citations.citations.size).to eq(1)
        expect(class_with_citations.save).to be_truthy
      end
    end

    context 'has_one' do
      specify '#source' do
        expect(class_with_citations).to respond_to(:source) 
      end

      specify '#source can be set with =' do
        expect(class_with_citations.source = source).to be_truthy
        expect(class_with_citations.save).to be_truthy
        expect(class_with_citations.source).to eq(source)
      end

      specify '#source can be set with nested attributes' do
        t = TestCitable.new( origin_citation_attributes: {source_id: source.to_param} )  
        expect(t.save).to be_truthy
        expect(t.citations(true).count).to eq(1)
        expect(t.citations.first.is_original?).to be_truthy
      end

      context 'with a is_original citation' do
        before do 
          citation.is_original = true
          class_with_citations.citations << citation
          class_with_citations.save!
        end

        specify 'returns original citation as #source' do
          expect(class_with_citations.source).to eq(Source.first)
        end
      end
    end
  end

  context 'instance methods' do
    specify 'cited? with no citations' do
      expect(class_with_citations.cited?).to eq(false)
    end

    specify '#cited? with some citations' do
      class_with_citations.citations << citation 
      expect(class_with_citations.cited?).to eq(true)
    end
  end

  context 'object with citations' do
    context 'on destroy' do
      specify 'attached citations are destroyed' do
        class_with_citations.save
        class_with_citations.citations << citation 
        expect(class_with_citations.citations.count).to eq(1)
        expect(class_with_citations.destroy)
        expect(Citation.count).to eq(0)
      end
    end
  end

  context 'ordering by source date' do
    let!(:a) { TestCitable.create }
    let!(:b) { TestCitable.create } 
    let!(:c) { TestCitable.create } 

    let(:youngest_source) { FactoryGirl.create(:valid_source_bibtex, year: Time.now.year) }
    let(:young_source) { FactoryGirl.create(:valid_source_bibtex, year: 2010) }
    let(:old_source) { FactoryGirl.create(:valid_source_bibtex, year: 1998) }
    let(:oldest_source) { FactoryGirl.create(:valid_source_bibtex, year: 1758) }
    let(:first_source_ever) { FactoryGirl.create(:valid_source_bibtex, year: 1700) }

    let(:nil_source) { FactoryGirl.create(:valid_source_bibtex, year: nil) }

    before do
      Citation.create(citation_object: a, source: oldest_source) 
      Citation.create(citation_object: b, source: young_source)                
      Citation.create(citation_object: c, source: old_source)   
    end

    context '.without_citations' do
      before do
        class_with_citations.save!
      end

      specify 'returns' do
        expect(TestCitable.without_citations).to eq([class_with_citations])
      end
    end

    specify "sanity test, 3 citations exist" do
      expect(Citation.count).to eq(3)
    end

    specify ".order_by_oldest_source_first" do
      expect(TestCitable.order_by_oldest_source_first.to_a).to eq([a, c, b])
    end

    specify ".oldest_by_citation" do
      expect(TestCitable.oldest_by_citation).to eq(a)
    end

    specify ".order_by_oldest_source_first.first" do
      expect(TestCitable.order_by_oldest_source_first.to_a.first).to eq(a)
    end

    specify '.order_by_yougest_source_first' do
      expect(TestCitable.order_by_youngest_source_first.to_a).to eq([b, c, a])
    end 

    specify ".youngest_by_citation" do
      expect(TestCitable.youngest_by_citation).to eq(b)
    end

    context 'reordering does not raise' do
     
      # presently raises, just don't do it, see comments
      # specify ".order_by_yougest_source_first.last" do
      #   expect{TestCitable.order_by_youngest_source_first.last}.to_not raise_error # not_raise # (TestCitable.oldest_by_citation).to eq(b)
      # end

      specify ".order_by_oldest_source_first.last" do
        expect{TestCitable.order_by_oldest_source_first.last}.to_not raise_error # not_raise # (TestCitable.oldest_by_citation).to eq(b)
      end
    end

    context 'with multiple citations' do
      context 'one of which is nil' do
        before do
          Citation.create(citation_object: c, source: nil_source)   
        end

        specify ".order_by_oldest_source_first.to_a" do
          expect(TestCitable.order_by_oldest_source_first.to_a).to eq([a, c, b])
        end

        specify ".oldest_by_citation" do
          expect(TestCitable.oldest_by_citation).to eq(a)
        end

        specify ".order_by_oldest_source_first.to_a.first" do
          expect(TestCitable.order_by_oldest_source_first.to_a.first).to eq(a)
        end

        specify '.order_by_yougest_source_first.to_a' do
          expect(TestCitable.order_by_youngest_source_first.to_a).to eq([b, c, a])
        end 

        specify ".youngest_by_citation" do
          expect(TestCitable.youngest_by_citation).to eq(b)
        end
      end

      context 'one of which is older' do
        before do
          Citation.create(citation_object: c, source: first_source_ever)   
        end

        specify ".order_by_oldest_source_first.to_a" do
          expect(TestCitable.order_by_oldest_source_first.to_a).to eq([c, a, b])
        end

        specify ".oldest_by_citation" do
          expect(TestCitable.oldest_by_citation).to eq(c)
        end

        specify ".order_by_oldest_source_first.to_a.first" do
          expect(TestCitable.order_by_oldest_source_first.to_a.first).to eq(c)
        end
      end

      context 'one of which is younger' do
        before do
          Citation.create(citation_object: c, source: youngest_source)   
        end

        specify '.order_by_yougest_source_first.to_a' do
          expect(TestCitable.order_by_youngest_source_first.to_a).to eq([c, b, a])
        end 

        specify ".youngest_by_citation" do
          expect(TestCitable.youngest_by_citation).to eq(c)
        end
      end
    end

    context 'with nils' do
      let!(:d) { TestCitable.create } 
    
      specify "with nils" do
        Citation.create(citation_object: d, source: nil_source)  
        expect(TestCitable.order_by_oldest_source_first.to_a).to eq([a,c,b,d])
      end
    end

  end

end

class TestCitable < ActiveRecord::Base
  include FakeTable
  include Shared::Citable
end
