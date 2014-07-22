# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'containable' do
  specify 'class includes Shared::Containable' do
    expect(described_class.ancestors.map(&:name).include?('Shared::Containable')).to be true
  end
end


