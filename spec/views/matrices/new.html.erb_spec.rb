require 'rails_helper'

RSpec.describe "matrices/new", type: :view do
  before(:each) do
    assign(:matrix, Matrix.new(
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project => nil
    ))
  end

  it "renders new matrix form" do
    render

    assert_select "form[action=?][method=?]", matrices_path, "post" do

      assert_select "input#matrix_name[name=?]", "matrix[name]"

      assert_select "input#matrix_created_by_id[name=?]", "matrix[created_by_id]"

      assert_select "input#matrix_updated_by_id[name=?]", "matrix[updated_by_id]"

      assert_select "input#matrix_project_id[name=?]", "matrix[project_id]"
    end
  end
end
