namespace :tw do
  namespace :coldp do

    desc 'Create a News::Project::Notice reminder for projects with COLDP export profiles. Run monthly via cron.'
    task news_reminder: [:environment] do
      Project.find_each do |project|
        profiles = project.coldp_profiles
        next if profiles.blank?

        # Skip if a current reminder already exists
        existing = News::Project::Notice
          .where(project_id: project.id)
          .where("title LIKE '%ColDP export%'")
          .current
          .exists?

        next if existing

        admin = project.project_administrators.first
        next unless admin

        Current.user_id = admin.id
        Current.project_id = project.id

        News::Project::Notice.create!(
          title: 'ColDP export reminder',
          body: "This is a monthly reminder to review your ColDP export profiles. " \
                "You have #{profiles.size} profile(s) configured. " \
                "Visit the ColDP Export Preferences task to review metadata, data quality, and ChecklistBank import status.",
          display_start: Time.current,
          display_end: 1.month.from_now,
          project_id: project.id,
          by: admin.id
        )

        puts "Created news reminder for project '#{project.name}' (id: #{project.id})"
      end
    end

  end
end
