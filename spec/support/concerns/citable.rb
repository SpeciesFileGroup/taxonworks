# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'citations' do
  specify 'class includes Shared::Citations' do
    expect(described_class.ancestors.map(&:name).include?('Shared::Citations')).to be true
  end
end


