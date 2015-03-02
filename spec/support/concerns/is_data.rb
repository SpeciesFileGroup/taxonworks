# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'is_data' do
  specify 'class includes Shared::IsData' do
    expect(described_class.ancestors.map(&:name).include?('Shared::IsData')).to be true
  end
end


