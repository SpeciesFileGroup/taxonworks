require 'spec_helper'

describe Protonym do

  let(:protonym) { Protonym.new }

  context "associations" do
    context "has_many" do
      specify "original_description_relationships" do 
        expect(protonym).to respond_to(:original_description_relationships)
      end
    end

    context "has_one" do
      specify "original_description_source" do
        expect(protonym).to respond_to(:original_description_source)
      end

      context "type_taxon_name_relationship" do

        context "typification" do

         before do
           # make the protonym a type of a genus
           type_taxon_name_relationship = TaxonNameRelationship.new(
                                                             subject: protonym,
                                                             object: FactoryGirl.create(:iczn_genus),
                                                             type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Original')
         end

         specify 'type_taxon_name' do
           expect(protonym).to respond_to(:type_taxon_name)
         end 

         specify 'type_taxon_name_relationship' do
           expect(protonym).to respond_to(:type_taxon_name_relatinship)
         end 
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_description_#{rank}_relationship" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end
      end

      context "taxon_names" do
        %w{genus subgenus species}.each do |rank|
          method = "original_#{rank}" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end
      end
    end
  end
end
