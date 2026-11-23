require 'rqrcode'

# Server-side rendering of QR codes. QR codes that carry authentication
# (e.g. a task_token) are only ever rendered here, never client-side.
module QrCodeHelper

  # @param text [String] the QR content
  # @return [String] a standalone SVG
  def qr_code_svg(text, module_size: 4)
    ::RQRCode::QRCode.new(text).as_svg(
      offset: module_size * 4,
      color: '000',
      fill: 'fff',
      shape_rendering: 'crispEdges',
      module_size:,
      standalone: true,
      use_path: true,
      viewbox: true,
      svg_attributes: { class: 'qr-code-svg' }
    ).to_s
  end

end
