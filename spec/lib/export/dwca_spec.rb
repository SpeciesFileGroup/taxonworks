require 'rails_helper'
require 'export/dwca'

describe Export::Dwca do

  specify "stores a compressed file in rails' temp directory" do
    path = Export::Dwca.get_archive
    expect(File.exists?(path)).to be_truthy
    File.delete(path)
    expect(path.to_s.index(Rails.root.join('tmp').to_s)).to eq(0)
  end

end
