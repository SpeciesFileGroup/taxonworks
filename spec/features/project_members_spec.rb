require 'rails_helper'

describe 'Project Members', type: :feature do

  context 'authorization with the world created' do 
    before { spin_up_project_and_users }

    let(:paths) {
      [
        many_new_project_members_path(project_member: {project_id: @project.id})
      ]
    }

    context 'as an administrator' do 
      before {  sign_in_with(@administrator.email, @password) }
      it_behaves_like 'is_authorized_when_signed_in_as_administator' do
        let(:administator) { @administrator }
      end
    end

    context 'as a user' do 
      before {  sign_in_with(@user.email, @password) }

      it_behaves_like 'is_not_authorized_when_signed_in_as_user' do
        let(:user) { @user }
      end
    end
  end


end

