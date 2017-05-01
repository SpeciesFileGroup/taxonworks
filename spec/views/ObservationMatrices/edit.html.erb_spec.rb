require 'rails_helper'

RSpec.describe "matrices/edit", type: :view do

  before(:each) do
    @matrix = assign(:matrix, ObservationMatrix.create!(
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project => nil
    ))
  end

  it "renders the edit matrix form" do
    render

    assert_select "form[action=?][method=?]", observationMatrix_path(@matrix), "post" do

      assert_select "input#matrix_name[name=?]", "matrix[name]"

      assert_select "input#matrix_created_by_id[name=?]", "matrix[created_by_id]"

      assert_select "input#matrix_updated_by_id[name=?]", "matrix[updated_by_id]"

      assert_select "input#matrix_project_id[name=?]", "matrix[project_id]"
    end
  end
end
