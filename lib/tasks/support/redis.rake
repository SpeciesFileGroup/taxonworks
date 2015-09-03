namespace :tw do
  namespace :redis do
    desc 'Initialization of Redis'
=begin
    On a command line:
      1)  brew install redis
      2)  ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
      3)  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
          or
          redis-server /usr/local/etc/redis.conf

      4)  gem install redis
          or
          (Include in Gemfile and) bundle install
=end

    task :init_redis do
      raise 'I\'m not ready yet....'
    end
  end
end
