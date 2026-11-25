module Match
  module Source
    class Field

      # The volume number alone: Source#volume often includes the issue,
      # `65(1)`, and a row's volume may include issue and pages.
      class Volume < Field

        def compare(row, source)
          volume = ::Utilities::Bibliography.volume_number(source.volume)

          {
            volume_match: (row.volume && volume) ?
              row.volume.casecmp?(volume) : nil
          }
        end

        def score(c)
          c[:volume_match] ? 1.0 : 0.0
        end

        def agrees?(c)
          c[:volume_match] == true
        end

      end
    end
  end
end
