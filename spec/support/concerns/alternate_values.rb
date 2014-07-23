# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'alternate_values' do
  specify 'class includes Shared::AlternateValues' do
    expect(described_class.ancestors.map(&:name).include?('Shared::AlternateValues')).to be true
  end
end


