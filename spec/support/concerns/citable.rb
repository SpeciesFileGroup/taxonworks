# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'citable' do
  specify 'class includes Shared::Citable' do
    expect(described_class.ancestors.map(&:name).include?('Shared::Citable')).to be true
  end
end


