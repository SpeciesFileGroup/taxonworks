require 'rails_helper'

describe 'STUB', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before {
      sign_in_user_and_select_project 
    }
  end
end
