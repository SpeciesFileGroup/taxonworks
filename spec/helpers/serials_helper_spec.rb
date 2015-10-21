require 'rails_helper'

describe SerialsHelper, :type => :helper do
  context 'a serial needs some helpers' do
    let(:name) {'dangerzone'}
    let(:serial) {FactoryGirl.create(:valid_serial, name:name)}

    specify '::serial_tag' do
      expect(helper.serial_tag(serial)).to eq(name)
    end

    specify '#serial_tag' do
      expect(helper.serial_tag(serial)).to eq(name)
    end

    specify '#serial_link' do
      expect(helper.serial_link(serial)).to have_link(name)
    end

    specify "#serial_search_form" do
      expect(helper.serials_search_form).to have_button('Show')
      expect(helper.serials_search_form).to have_field('serial_id_for_quick_search_form')
    end

  end
end
