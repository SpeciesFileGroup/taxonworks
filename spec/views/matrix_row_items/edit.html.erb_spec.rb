require 'rails_helper'

RSpec.describe "matrix_row_items/edit", type: :view do
  before(:each) do
    @matrix_row_item = assign(:matrix_row_item, MatrixRowItem.create!(
      :matrix => nil,
      :type => "",
      :collection_object => nil,
      :otu => nil,
      :keyword => nil,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project => nil
    ))
  end

  it "renders the edit matrix_row_item form" do
    render

    assert_select "form[action=?][method=?]", matrix_row_item_path(@matrix_row_item), "post" do

      assert_select "input#matrix_row_item_matrix_id[name=?]", "matrix_row_item[matrix_id]"

      assert_select "input#matrix_row_item_type[name=?]", "matrix_row_item[type]"

      assert_select "input#matrix_row_item_collection_object_id[name=?]", "matrix_row_item[collection_object_id]"

      assert_select "input#matrix_row_item_otu_id[name=?]", "matrix_row_item[otu_id]"

      assert_select "input#matrix_row_item_keyword_id[name=?]", "matrix_row_item[keyword_id]"

      assert_select "input#matrix_row_item_created_by_id[name=?]", "matrix_row_item[created_by_id]"

      assert_select "input#matrix_row_item_updated_by_id[name=?]", "matrix_row_item[updated_by_id]"

      assert_select "input#matrix_row_item_project_id[name=?]", "matrix_row_item[project_id]"
    end
  end
end
