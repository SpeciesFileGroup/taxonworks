module Match
  module Source
    class Field

      # The volume number alone: Source#volume often includes the issue,
      # `65(1)`, and a row's volume may include issue and pages.
      class Volume < Field

        # A volume's label, `Vol. 10`, `Volume 10`.
        LABEL_PATTERN = /\Avol(?:ume)?\.?\s*/i

        # @param value [String, nil] a volume, optionally labelled and followed
        #   by issue and pages, e.g. `10(2):149-158`, `65(1)`, `Vol. 10 (2)`
        # @return [String, nil] the volume alone, e.g. `10`
        def self.number(value)
          value.to_s.strip.sub(LABEL_PATTERN, '')[/\A([^\s(:,;]+)/, 1]
        end

        def self.source_columns
          %i{volume}
        end

        def compare(row, source)
          volume = self.class.number(source.volume)

          {
            volume_match: (row.volume && volume) ?
              row.volume.casecmp?(volume) : nil
          }
        end

        def score(c)
          c[:volume_match] ? 1.0 : 0.0
        end

      end
    end
  end
end
