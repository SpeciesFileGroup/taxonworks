# frozen_string_literal: true

# CLib is required to free memory after it is used by C
module CLib
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function :free, [:pointer], :void
end

module Biodiversity
  # Parser provides a namespace for functions to parse scientific names.
  module Parser
    extend FFI::Library

    platform = case Gem.platforms[1].os
               when 'linux'
                 'linux'
               when 'darwin'
                 'mac'
               when 'mingw32'
                 'win'
               else
                 raise "Unsupported platform: #{Gem.platforms[1].os}"
               end
    ffi_lib File.join(__dir__, '..', '..', 'clib', platform, 'libgnparser.so')
    POINTER_SIZE = FFI.type_size(:pointer)

    callback(:parser_callback, %i[string], :void)

    attach_function(:parse_go, :ParseToString,
                    %i[string string parser_callback], :void)
    attach_function(:parse_ary_go, :ParseAryToStrings,
                    %i[pointer int string parser_callback], :void)

    def self.parse(name, simple = false)
      format = simple ? 'simple' : 'compact'

      parsed = nil
      parse_go(name, format) { |str| parsed = str }
      output(parsed, simple)
    end

    def self.parse_ary(ary, simple = false)
      format = simple ? 'simple' : 'compact'
      in_ptr = FFI::MemoryPointer.new(:pointer, ary.length)

      in_ptr.write_array_of_pointer(
        ary.map { |s| FFI::MemoryPointer.from_string(s) }
      )

      out_ary = []
      parse_ary_go(in_ptr, ary.length, format) { |str| out_ary << output(str, simple) }
      out_ary
    end

    def self.output(parsed, simple)
      if simple
        csv = CSV.new(parsed)
        parsed = csv.read[0]
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
  end
end
