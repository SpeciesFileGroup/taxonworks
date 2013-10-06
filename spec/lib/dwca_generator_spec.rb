require 'spec_helper'
require 'dwca_generator'

describe DwcaGenerator do
  
  specify "stores a compressed file in rails' temp directory" do
    path = DwcaGenerator.get_archive
    expect(File.exists?(path)).to be_true
    File.delete(path)
    expect(path.to_s.index(Rails.root.join('tmp').to_s)).to eq(0)
  end
end
