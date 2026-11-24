module Vendor

  # A middle-layer wrapper between Prawn and TaxonWorks, adding font
  # registration for characters outside Prawn's default fonts. The default
  # Prawn raises Prawn::Errors::IncompatibleStringEncoding on anything
  # outside Windows-1252 (diacritics, CJK, etc).
  #
  # Fonts come from OS packages (see Dockerfile.base), not the repo. Paths
  # default to where Ubuntu installs them and can be overridden by ENV for
  # other platforms.
  module Prawn

    # Installed by Ubuntu's fonts-liberation package. Covers Latin, Cyrillic
    # and Greek, including diacritics.
    LIBERATION_SANS_DIR = ENV.fetch(
      'TW_LIBERATION_SANS_DIR',
      '/usr/share/fonts/truetype/liberation'
    ).freeze

    LIBERATION_SANS_REGULAR = File.join(
      LIBERATION_SANS_DIR, 'LiberationSans-Regular.ttf'
    ).freeze

    LIBERATION_SANS_BOLD = File.join(
      LIBERATION_SANS_DIR, 'LiberationSans-Bold.ttf'
    ).freeze

    LIBERATION_SANS_ITALIC = File.join(
      LIBERATION_SANS_DIR, 'LiberationSans-Italic.ttf'
    ).freeze

    LIBERATION_SANS_BOLD_ITALIC = File.join(
      LIBERATION_SANS_DIR, 'LiberationSans-BoldItalic.ttf'
    ).freeze

    # Installed by Ubuntu's fonts-droid-fallback package. Covers CJK.
    CJK_FONT_PATH = ENV.fetch(
      'TW_CJK_FONT_PATH',
      '/usr/share/fonts-droid-fallback/truetype/DroidSansFallback.ttf'
    ).freeze

    CJK_FONT_FAMILY = 'DroidSansFallback'.freeze

    def self.cjk_font_available?
      File.file?(CJK_FONT_PATH)
    end

    def self.font_families
      families = {
        'LiberationSans' => {
          normal: LIBERATION_SANS_REGULAR,
          bold: LIBERATION_SANS_BOLD,
          italic: LIBERATION_SANS_ITALIC,
          bold_italic: LIBERATION_SANS_BOLD_ITALIC
        }
      }

      # Single-style font; register it for every style so <b>/<i> markup in
      # CJK text still resolves.
      if cjk_font_available?
        families[CJK_FONT_FAMILY] = {
          normal: CJK_FONT_PATH,
          bold: CJK_FONT_PATH,
          italic: CJK_FONT_PATH,
          bold_italic: CJK_FONT_PATH
        }
      end

      families
    end

    # @return [Array<String>] the `fallback_fonts:` argument for `pdf.text`
    def self.cjk_fallback
      cjk_font_available? ? [CJK_FONT_FAMILY] : []
    end

    # A new ::Prawn::Document with TW's fonts registered, `string` rendered
    # on it with the CJK fallback font applied whenever it's available.
    def self.text(string, **options)
      pdf = ::Prawn::Document.new
      pdf.font_families.update(font_families)
      pdf.font('LiberationSans')
      pdf.text(string, **options, fallback_fonts: cjk_fallback)
      pdf
    end

  end
end
