module Utilities
  class PageMap

    # One member of a RangeSet. Either a singleton or a generated run.
    #
    # This class was substantially authored by Claude.
    class Segment
      attr_reader :type, :from, :to, :step, :template, :value

      def self.build(raw)
        case raw
        when Segment then raw
        when Integer then new(type: :literal, value: raw)
        when String then new(type: :literal, value: raw)
        when Hash then from_hash(raw)
        else
          raise(FormatError, "cannot read range set member: #{raw.inspect}")
        end
      end

      def self.from_hash(raw)
        hash = raw.transform_keys(&:to_s)

        if hash.key?('template')
          return new(
            type: :template,
            template: hash['template'],
            from: Integer(hash.fetch('from', 1)),
            to: Integer(hash.fetch('to', 1))
          )
        end

        unless hash.key?('from') && hash.key?('to')
          raise(FormatError, "range member needs 'from' and 'to': #{raw.inspect}")
        end

        from = hash['from']
        to = hash['to']
        roman_bounds = Utilities::Roman.roman?(from) && Utilities::Roman.roman?(to)

        if hash['roman'] && !roman_bounds
          raise(FormatError, "range member declared roman but its bounds are not: #{raw.inspect}")
        elsif roman_bounds
          new(type: :roman, from: Utilities::Roman.to_i(from), to: Utilities::Roman.to_i(to))
        elsif from.is_a?(Integer) && to.is_a?(Integer)
          new(type: :integer, from:, to:, step: Integer(hash.fetch('step', 1)))
        else
          raise(FormatError, "range member must be integer or roman: #{raw.inspect}")
        end
      end

      def initialize(type:, from: nil, to: nil, step: 1, template: nil, value: nil)
        @type = type
        @from = from
        @to = to
        @step = step.nil? || step.zero? ? 1 : step
        @template = template
        @value = value

        if %i[integer roman template].include?(type) && from > to
          raise(FormatError, "range runs backwards: #{from}..#{to}")
        end
      end

      def integer_like?
        type == :integer || (type == :literal && value.is_a?(Integer))
      end

      # Bounds as integers, for merging. Only meaningful when integer_like?.
      def bounds
        type == :integer ? [from, to] : [value, value]
      end

      def size
        case type
        when :literal then 1
        when :integer then ((to - from) / step) + 1
        when :roman, :template then to - from + 1
        end
      end

      def to_a
        raise(ExpansionError, "range too large to expand: #{size}") if size > MAX_EXPANSION

        case type
        when :literal then [value]
        when :integer then from.step(to, step).to_a
        when :roman then (from..to).map { |n| Utilities::Roman.from_i(n) }
        when :template then (from..to).map { |n| format(template, n) }
        end
      end

      def include?(candidate)
        case type
        when :literal
          value == candidate || value.to_s == candidate.to_s
        when :integer
          candidate.is_a?(Integer) && candidate.between?(from, to) &&
            ((candidate - from) % step).zero?
        when :roman, :template
          to_a.include?(candidate)
        end
      end

      def as_json
        case type
        when :literal then value
        when :integer
          out = { 'from' => from, 'to' => to }
          out['step'] = step unless step == 1
          out
        when :roman
          { 'from' => Utilities::Roman.from_i(from), 'to' => Utilities::Roman.from_i(to), 'roman' => true }
        when :template
          { 'template' => template, 'from' => from, 'to' => to }
        end
      end

      def ==(other)
        other.is_a?(Segment) && as_json == other.as_json
      end
    end
  end
end
