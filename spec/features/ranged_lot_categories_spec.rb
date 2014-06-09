require 'spec_helper'

describe 'RangedLotCategories', base_class: RangedLotCategory do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /ranged_lot_categories' do
    before { visit ranged_lot_categories_path }
    specify 'an index name is present' do
      expect(page).to have_content('Ranged Lot Categories')
    end
  end
end
