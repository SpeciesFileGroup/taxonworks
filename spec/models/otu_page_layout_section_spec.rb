require 'rails_helper'

# Get the subclasses
Dir[Rails.root.to_s + '/app/models/otu_page_layout_section/**/*.rb'].sort.each {|file| require file }

describe OtuPageLayoutSection, :type => :model do
  let(:otu_page_layout_section) {FactoryGirl.build(:otu_page_layout_section)} 
  context 'validation' do
    specify '"foo" is a legal type' do
      expect{OtuPageLayoutSection.new(type: "foo")}.to raise_error ActiveRecord::SubclassNotFound
    end

    OtuPageLayoutSection.descendants.each do |d|
      specify "#{d.name} is a legal type" do
        otu_page_layout_section.type = d.name 
        otu_page_layout_section.valid?
        expect(otu_page_layout_section.errors.include?(:type)).to be_falsey
      end
    end
  end
end
