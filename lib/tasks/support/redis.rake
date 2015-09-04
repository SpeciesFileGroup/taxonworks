namespace :tw do
  namespace :redis do
    desc 'Initialization of Redis'
=begin
  Redis performance: redis.conf should replace /usr/local/etc/redis.conf so that there is no disk save file. See line
  120 for more information.
  In our case (for the moment: 09/04/15), we are only using this for a speed enhancement for insect.rake.
  To use this config file, copy it to the indicated directory, and stop/start redis:
    launchctl stop homebrew.mxcl.redis
    launchctl start homebrew.mxcl.redis

    On a command line:
      1)  brew install redis
      2)  ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
      3)  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
          or
          redis-server /usr/local/etc/redis.conf

      4)  gem install hiredis, redis
          or
          (Include in Gemfile and) bundle install

  Look for more information on the gem at http://www.rubydoc.info/gems/redis/3.2.1

=end

    task :init_redis do
      # raise 'I\'m not ready yet....'
      test_redis = Redis.new
      redis_id = 'redis://127.0.0.1:6379/0'

      begin
        test_redis.ping
      rescue Exception => e
        e.inspect
# => #<Redis::CannotConnectError: Timed out connecting to Redis on 10.0.1.1:6380>

        e.message
# => Timed out connecting to Redis on 10.0.1.1:6380
        puts "#{e.inspect}"
        e.inspect
      end

      test_redis.set('Able', 'Baker')
      if test_redis.get('Able') != 'Baker'
        raise 'Redis may not be installed...'
      end

      if test_redis.id != redis_id
        raise "Redis does not seem to be properly configured (#{redis_id})"
      end

      test_redis.set('this is the key', [1, 2, 3].to_json)

      puts "Redis installed as ''#{redis_id}''"
      test_redis.flushall
      test_redis
    end

    desc 'Add code here to experiment with Redis'
    task :redis_experiment => [:init_redis] do

    end
  end
end
