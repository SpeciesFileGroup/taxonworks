module IconsHelper

  class IconNotFound < StandardError; end

  ICON_DIRECTORY = Rails.root.join('app/assets/images/icons').freeze

  ICON_NAME_FORMAT = /\A[a-z0-9-]+\z/

  ICON_CACHE = Concurrent::Map.new

  def icon(name, size: 16, **overrides)
    definition = IconsHelper.icon_definition(name.to_s)
    attributes = definition[:attributes].merge(
      overrides.transform_keys { |key| key.to_s.dasherize.to_sym },
      width: size,
      height: size
    )
    content_tag(:svg, definition[:content], attributes)
  end

  def self.icon_definition(name)
    return load_icon(name) if Rails.application.config.enable_reloading
    ICON_CACHE.compute_if_absent(name) { load_icon(name) }
  end

  def self.load_icon(name)
    path = ICON_DIRECTORY.join("#{name}.svg")
    unless name.match?(ICON_NAME_FORMAT) && path.file?
      raise IconNotFound, "Icon not found: '#{name}'" unless Rails.env.production?
      return { attributes: {}, content: ''.html_safe }.freeze
    end

    svg = Nokogiri::XML(path.read).root
    attributes = svg.namespace_definitions.to_h { |ns| [[:xmlns, ns.prefix].compact.join(':').to_sym, ns.href] }
      .merge(svg.attributes.except('width', 'height').to_h { |key, attribute| [key.to_sym, attribute.value] })
    { attributes:, content: svg.element_children.map(&:to_xml).join.html_safe }.freeze
  end

end
