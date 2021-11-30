shared_examples 'has_roles' do
  specify 'class includes Shared::IsData::HasRoles' do
    expect(described_class.ancestors.map(&:name).include?('Shared::IsData::HasRoles')).to be true
  end
end



