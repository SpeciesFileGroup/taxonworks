# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'documentation' do
  specify 'class includes Shared::Documentation' do
    expect(described_class.ancestors.map(&:name).include?('Shared::Documentation')).to be true
  end
end


