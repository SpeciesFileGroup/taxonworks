module Vendor

  # A middle-layer wrapper between Prawn and TaxonWorks, adding font
  # registration for characters outside Prawn's default fonts. The default
  # Prawn raises Prawn::Errors::IncompatibleStringEncoding on anything
  # outside Windows-1252 (diacritics, CJK, etc).
  module Prawn

    LIBERATION_SANS_REGULAR = Rails.root.join(
      'vendor', 'assets', 'fonts', 'liberation_sans', 'LiberationSans-Regular.ttf'
    ).to_s
    LIBERATION_SANS_BOLD = Rails.root.join(
      'vendor', 'assets', 'fonts', 'liberation_sans', 'LiberationSans-Bold.ttf'
    ).to_s
    LIBERATION_SANS_ITALIC = Rails.root.join(
      'vendor', 'assets', 'fonts', 'liberation_sans', 'LiberationSans-Italic.ttf'
    ).to_s
    LIBERATION_SANS_BOLD_ITALIC = Rails.root.join(
      'vendor', 'assets', 'fonts', 'liberation_sans', 'LiberationSans-BoldItalic.ttf'
    ).to_s

    # Installed by exe/install-source-han-sans.sh into the Docker base
    # image (see Dockerfile.base) - not vendored in the repo, it's ~34MB.
    # Present in production/staging containers; absent in local dev and CI,
    # where CJK fallback is simply unavailable and Latin/Cyrillic/Greek
    # diacritics (LiberationSans, always present) still work normally.
    CJK_FONT_PATH = '/usr/local/share/fonts/source-han-sans/SourceHanSans-Regular.ttf'.freeze

    def self.cjk_font_available?
      File.exist?(CJK_FONT_PATH)
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
      families['SourceHanSans'] = { normal: CJK_FONT_PATH } if cjk_font_available?

      families
    end

    # @return [Array<String>] the `fallback_fonts:` argument for `pdf.text`
    def self.cjk_fallback
      cjk_font_available? ? ['SourceHanSans'] : []
    end

    # A new ::Prawn::Document with TW's vendored fonts registered, `string`
    # rendered on it with the CJK fallback font applied whenever it's
    # available.
    def self.text(string, **options)
      pdf = ::Prawn::Document.new
      pdf.font_families.update(font_families)
      pdf.font('LiberationSans')
      pdf.text(string, **options, fallback_fonts: cjk_fallback)
      pdf
    end

  end
end
