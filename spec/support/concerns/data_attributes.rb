# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'data_attributes' do
  specify 'class includes Shared::DataAttributes' do
    expect(described_class.ancestors.map(&:name).include?('Shared::DataAttributes')).to be true
  end
end



