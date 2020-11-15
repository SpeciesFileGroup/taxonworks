user = User.create!(
  name: 'John Doe',
  email: 'admin@example.com',
  password: 'taxonworks',
  password_confirmation: 'taxonworks',
  is_administrator: true,
  self_created: true
)

project = Project.create(
  name: "test_project",
  by: user
)

ProjectMember.create!(
  project: project,
  user: user,
  by: user
)

taxon_name = Protonym.create!(
  name: "Testidae",
  rank_class: Ranks.lookup(:iczn, 'Family'),
  parent: project.root_taxon_name,
  project: project,
  by: user
)

otu = Otu.create!(
  name: 'test_otu',
  taxon_name: taxon_name,
  project: project,
  by: user
)

# Verify we don't run all queues
ShouldNotRunJob.perform_later(otu)
