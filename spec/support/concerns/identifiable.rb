# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'identifiable' do
  
  specify 'class includes Shared::Identifiable' do
    expect(described_class.ancestors.map(&:name).include?('Shared::Identifiable')).to be true
  end

end

