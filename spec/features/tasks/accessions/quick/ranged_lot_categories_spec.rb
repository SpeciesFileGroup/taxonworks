require 'rails_helper'

describe 'photo based data capture', :type => :feature do


  context 'GET /quick_accession_from_image' do

    skip 'render some form elements and maybe instructions'

    context 'capturing the image' do
      skip 'an image is added to a form via a *camera* click'
      skip 'as a fallback an image can be added by clicking browse on the form'
    end

  end

  context 'linking results from sqed parsing to TW models' do

    context 'breaking down the image' do

      # This will play against the sqed gem

    end

    context 'OCR parsing' do

      # Comes completely from sqed gem

    end

    context 'barcode recognition' do

    end

  end


end
