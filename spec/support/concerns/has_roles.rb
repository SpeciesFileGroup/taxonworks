# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'has_roles' do
  specify 'class includes Shared::HasRoles' do
    expect(described_class.ancestors.map(&:name).include?('Shared::HasRoles')).to be true
  end
end



