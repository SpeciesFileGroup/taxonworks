namespace :db do

  desc 'Drop, create, migrate the development or test databases only.'  
  task :rebuild => [:environment] do
    raise if not %w{development test}.include?(Rails.env)
    Rails.env ||= 'development' 
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end

  desc 'Rebuild then seed the development database.'
  task :build_seeded_development => [:rebuild] do
    raise "\n\n#{Rails.env} database rebuilt but not seeded. Seeding can only be used with the development database.\n\n" if Rails.env != 'development' 
    Rake::Task["db:seed"].invoke
  end


end

