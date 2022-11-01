require 'rqrcode'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/svg_outputter'

module LabelsHelper

  # !! Note that `label_tag` is a Rails method, so we have to append and make exceptions
  def taxonworks_label_tag(label)
    return nil if label.nil?
    case label.type
    when 'Label::QrCode'
      label_svg_tag(label)
    when 'Label::Code128'
      label_code_128_tag(label)
    when 'Label::UnitTray::Header1'
      label_unit_tray_header1_tag(label)
    else
      content_tag(:span, label.text, style: label.style) # TODO: properly reference style
    end
  end

  def label_link(label)
    return nil if label.nil?
    if label.label_object_id.blank?
      taxonworks_label_tag(label)
    else
      link_to(content_tag(:span, label.text), print_labels_task_path(label_id: label.to_param))
    end
  end

  def label_unit_tray_header1_tag(label)
    o = label.label_object
    tag.span(
      tag.span(
        tag.span(full_taxon_name_tag(o), class: 'unit_tray_header1_left') +
        tag.span(o.id, class: 'unit_tray_header1_right'),
        class: 'unit_tray_header1_top'
      ) +
      "\n" +
      tag.span(
        [o.taxonomy['order'], o.taxonomy['family']].compact.join(': '), class: 'unit_tray_header1_bottom'
      ), class: 'foo') 
  end

  def label_svg_tag(label)
    c = ::RQRCode::QRCode.new(label.text)

    content_tag(
      :span, 
      content_tag(:span, label.text, class: 'qrcode_text') +
      content_tag(
        :span, 
        c.as_svg(
          offset: 0,
          color: '000',
          shape_rendering: 'crispEdges',
          module_size: 1,
          standalone: true,
          viewbox: true,
          svg_attributes: {
            class: :qrcode_svg
          }
        ).to_s.html_safe,
        class: :qrcode_barcode
      ),
      class: :qrcode
    )
  end

  def label_code_128_tag(label)
    c = Barby::Code128.new(label.text)

    content_tag(
      :span, 

      content_tag(
        :span, 
        c.to_svg(xmargin: 0, ymargin: 0).html_safe,
        class: :code128_barcode
      ) +
      content_tag(:span, label.text, class: 'code128_text'),
      class: :code128
    )
  end

end
