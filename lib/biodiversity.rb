module Biodiversity
  module Parser
    
    def self.parse(name, simple = false)
      parsed = simple ? parse_go_simple(name) : parse_go_compact(name)
      output(parsed, simple)
    end

    def self.output(parsed, simple)
      if simple
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
      else
        JSON.parse(parsed, symbolize_names: true)
      end
    end

    private

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

  end
end