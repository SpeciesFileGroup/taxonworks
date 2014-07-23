# See spec/models/concerns/shared/taggable.rb for functional tests on a fake Model, this only tests for include
shared_examples 'taggable' do
  specify 'class includes Shared::Taggable' do
    expect(described_class.ancestors.map(&:name).include?('Shared::Taggable')).to be true
  end
end

