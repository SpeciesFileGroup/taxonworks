module Biodiversity
  module Parser
    
    def self.parse(name, simple = false)
      parsed = simple ? parse_go_simple(name) : parse_go_compact(name)
      output(parsed, simple)
    end

    def self.parse_ary(names, simple = false)
      parsed = simple ? parse_go_simple_ary(names) : parse_go_compact_ary(names)
      ary = output_ary(parsed, simple)

      lut = {}
      ary.each { |x| lut[x[:verbatim]] = x }

      names.map { |x| lut[x] }
    end

    private

    def self.output(parsed, simple)
      if simple
        output_simple(parsed)
      else
        output_compact(parsed)
      end
    end

    def self.output_simple(parsed)
      parsed = parsed.split('|')
      {
        id: parsed[0],
        verbatim: parsed[1],
        canonicalName: {
          full: parsed[2],
          simple: parsed[3],
          stem: parsed[4]
        },
        authorship: parsed[5],
        year: parsed[6],
        quality: parsed[7]
      }
    end

    def self.output_compact(parsed)
      JSON.parse(parsed, symbolize_names: true)
    end

    def self.output_ary(parsed_ary, simple)
      if simple
        parsed_ary.map! { |parsed| output_simple(parsed) }
      else
        parsed_ary.map! { |parsed| output_compact(parsed) }
      end
    end

    def self.start_gnparser
      io = {}
      
      ['compact', 'simple'].each do |format|
        stdin, stdout, stderr = Open3.popen3("gnparser --format #{format}")
        io[format.to_sym] = { stdin: stdin, stdout: stdout, stderr: stderr }
      end
      io
    end

    @@semaphore = Mutex.new
    @@io = start_gnparser

    def self.parse_go(name, format)
      @@semaphore.synchronize do
        @@io[format][:stdin].puts(name)
        @@io[format][:stdout].gets
      end
    end

    def self.parse_go_compact(name)
      parse_go(name, :compact)
    end

    def self.parse_go_simple(name)
      parse_go(name, :simple)
    end

    def self.parse_go_ary(names, format)
      ary = []
      @@semaphore.synchronize do
        len = names.length

        Thread.new { @@io[format][:stdin].puts(names) }
        t = Thread.new { len.times { ary << @@io[format][:stdout].gets } }

        t.join
      end
      ary
    end

    def self.parse_go_compact_ary(names)
      parse_go_ary(names, :compact)
    end

    def self.parse_go_simple_ary(names)
      parse_go_ary(names, :simple)
    end

  end
end
