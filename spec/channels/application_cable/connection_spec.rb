require 'rails_helper'

describe ApplicationCable::Connection, type: :channel do
  let(:user) { FactoryBot.create(:valid_user) }

  specify 'rejects a connection without a remember_token' do
    expect { connect '/cable' }.to have_rejected_connection
  end

  specify 'rejects a connection with an unknown remember_token' do
    cookies[:remember_token] = 'not_a_token'
    expect { connect '/cable' }.to have_rejected_connection
  end

  specify 'identifies the User from a valid remember_token' do
    remember_token = User.secure_random_token
    user.update_column(:remember_token, User.encrypt(remember_token))

    cookies[:remember_token] = remember_token
    connect '/cable'

    expect(connection.current_user).to eq(user)
  end
end
