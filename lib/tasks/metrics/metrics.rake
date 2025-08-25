require 'fileutils'

namespace :tw do

  namespace :metrics do

    task total_records: [:environment] do

      t = 0
      ApplicationEnumeration.project_data_classes.each do |c|
        i = c.count
        puts c.name + ": #{i}"
        t += i
      end
    
      puts 
      puts "Total: #{t}" 
    end

    task records_updated: [:environment] do
      m = ENV['months'] || 6

      t = 0
      ApplicationEnumeration.project_data_classes.each do |c|
        next unless c.new.respond_to?(:updated_at)
        i = c.where(updated_at: m.months.ago..Time.now).count
        puts c.name + ": #{i}"
        t += i
      end
    
      puts 
      puts "Total (#{m}): #{t}" 
    end

    task records_created: [:environment] do
      m = ENV['months'] || 6

      t = 0
      ApplicationEnumeration.project_data_classes.each do |c|
        next unless c.new.respond_to?(:created_at)
        i = c.where(created_at: m.months.ago..Time.now).count
        puts c.name + ": #{i}"
        t += i
      end
    
      puts 
      puts "Total (#{m}): #{t}" 
    end

    task records_updated: [:environment] do
      m = ENV['months'] || 6

      t = 0
      ApplicationEnumeration.project_data_classes.each do |c|
        next unless c.new.respond_to?(:updated_at)
        i = c.where(updated_at: m.months.ago..Time.now).count
        puts c.name + ": #{i}"
        t += i
      end
    
      puts 
      puts "Total (#{m}): #{t}" 
    end

    task records_updated_by: [:environment] do
      m = ENV['months'] || 6

      use = Hash.new(0)

      User.where('time_active > 0').each do |u|
        print u.name + ': '
        
        ApplicationEnumeration.project_data_classes.each do |c|
          k = c.new
          next unless k.respond_to?(:updated_at) && k.respond_to?(:updated_by_id)
          i = c.where(updated_at: m.months.ago..Time.now, updated_by_id: u.id).count
          use[u.id] += i
        end

        puts use[u.id]
      end

      puts

      puts use.sort{|a,b| a.last <=> b.last }.to_h
    end

    task records_created_by: [:environment] do
      m = ENV['months'] || 6

      use = Hash.new(0)

      User.where('time_active > 0').each do |u|
        print u.name + ': '
        
        ApplicationEnumeration.project_data_classes.each do |c|
          k = c.new
          next unless k.respond_to?(:created_at) && k.respond_to?(:created_by_id)
          i = c.where(created_at: m.months.ago..Time.now, created_by_id: u.id).count
          use[u.id] += i
        end

        puts use[u.id]
      end

      puts

      puts use.sort{|a,b| a.last <=> b.last }.to_h
    end

  end
end

