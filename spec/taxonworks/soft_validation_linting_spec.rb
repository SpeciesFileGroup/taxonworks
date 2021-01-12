require 'rspec'
require 'rails_helper'

# These tests ensure that resolution: attributes set for soft_validate() methods exist in the application
describe TaxonWorks, group: [:soft_validation, :lint], type: :model, lint: :true do
  Rails.application.eager_load!

  context 'model includes/attributes' do
    let(:paths) { Rails.application.routes.named_routes }
    ApplicationRecord.descendants.each { |model|

      if model < SoftValidation
  #     it "#{model} has soft validations resolutions for routes that exist" do
  #       model.soft_validation_methods.each do 
  #         exepect(paths).to contain() 
  #       end
  #     end
      end
    }
  end

end

