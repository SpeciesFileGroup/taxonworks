namespace :autoselect do
  desc 'Lint autoselect id uniqueness across views, helpers, and Vue components'
  task lint_ids: :environment do
    roots = %w[app/views app/helpers app/javascript/vue]
    globs = roots.flat_map { |r| [File.join(r, '**/*.erb'), File.join(r, '**/*.html'), File.join(r, '**/*.vue')] }

    # Match: class="autoselect" ... id="some-id"  OR  id="some-id" ... class="autoselect"
    # Also matches :id="..." (Vue dynamic binding) and id='...' (single quotes)
    id_pattern = /class=["']autoselect["'][^>]*\bid=["']([^"']+)["']|
                  \bid=["']([^"']+)["'][^>]*class=["']autoselect["']/x

    occurrences = Hash.new { |h, k| h[k] = [] }

    globs.each do |g|
      Dir[g].each do |file|
        File.foreach(file).with_index(1) do |line, lineno|
          line.scan(id_pattern) do |m1, m2|
            id = (m1 || m2).strip
            next if id.start_with?('autoselect_') # auto-generated UUID suffix; skip
            occurrences[id] << "#{file}:#{lineno}"
          end
        end
      end
    end

    duplicates = occurrences.select { |_id, locs| locs.size > 1 }

    if duplicates.empty?
      puts Rainbow('autoselect:lint_ids — all ids are unique.').green
    else
      puts Rainbow("autoselect:lint_ids — #{duplicates.size} duplicate id(s) found:").red
      duplicates.each do |id, locs|
        puts "  id=\"#{id}\""
        locs.each { |loc| puts "    #{loc}" }
      end
      abort
    end
  end
end
