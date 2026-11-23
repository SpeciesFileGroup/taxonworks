require 'rails_helper'

describe Support::Database do

  specify '.primary_config is the primary database configuration' do
    expect(Support::Database.primary_config[:database]).to eq(ApplicationRecord.connection.current_database)
  end

  specify '.primary_config is not the solid database configuration' do
    solid = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'solid')
    expect(Support::Database.primary_config[:database]).not_to eq(solid.database)
  end

end
