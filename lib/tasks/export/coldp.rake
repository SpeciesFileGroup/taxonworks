namespace :tw do
  namespace :coldp do

    desc 'Create a News::Project::Notice reminder for projects opted in to COL publication reminders. Run monthly via cron.'
    task news_reminder: [:environment] do
      Project.find_each do |project|
        profiles = project.coldp_profiles
        next if profiles.blank?

        settings = project.coldp_settings
        next unless settings['col_publication_reminder'] == true

        # Skip if a current reminder already exists
        existing = News::Project::Notice
          .where(project_id: project.id)
          .where("title LIKE '%COL publication%'")
          .current
          .exists?

        next if existing

        admin = project.project_administrators.first
        next unless admin

        Current.user_id = admin.id
        Current.project_id = project.id

        today = Date.current
        publication_date = Date.new(today.year, today.month, 16)

        News::Project::Notice.create!(
          title: 'COL publication reminder',
          body: "Your data will be published in the next Catalogue of Life release. " \
                "You have #{profiles.size} ColDP export profile(s) configured. " \
                "Visit the ColDP Export Preferences task to review metadata, data quality, and ChecklistBank import status before the publication date.",
          display_start: Time.current,
          display_end: publication_date.end_of_day,
          project_id: project.id,
          by: admin.id
        )

        puts "Created COL publication reminder for project '#{project.name}' (id: #{project.id})"
      end
    end

  end
end
