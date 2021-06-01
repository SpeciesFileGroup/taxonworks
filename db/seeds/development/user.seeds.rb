raise 'not so fast' if Rails.env.production?

unless $user_seed_ran ||= false
  $user_seed_ran = true

  begin
    admin, user, project = nil, nil, nil
    ApplicationRecord.transaction do
      if User.where(is_administrator: true).any?
        raise TaxonWorks::SeedError, Rainbow('An administrator exists.').red
      else
        admin = User.create!(name:                  'Development Administrator',
                            email:                 'admin@example.com',
                            password:              'taxonworks',
                            password_confirmation: 'taxonworks',
                            is_administrator:      true,
                            self_created:          true)
      end

      if User.where.not(is_administrator: true).any?
        raise TaxonWorks::SeedError, Rainbow('A user exists.').red
      else
        user = User.create!(name:                  'Development User',
                            email:                 'user@example.com',
                            password:              'taxonworks',
                            password_confirmation: 'taxonworks',
                            self_created:          true)
      end
    end

    project = Project.create!(name: 'Default', by: admin)
    [admin, user].each { |u| ProjectMember.create!(project: project, user: u, by: admin) }

    # Used by matrix seed when env vars are not set
    Current.user_id = user.id
    Current.project_id = project.id
    ###

    puts Rainbow("Created an administrator #{admin.email}, a user #{user.email} (both with password 'taxonworks'), and project #{project.name} with them in it.").blue
  rescue ActiveRecord::RecordInvalid => e
    puts Rainbow("Failed with #{e.error.full_messages.join(', ')}.").red
  rescue TaxonWorks::SeedError => e
    puts e.message
  rescue
    raise
  end
end
