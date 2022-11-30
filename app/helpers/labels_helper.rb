require 'rqrcode'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/svg_outputter'

module LabelsHelper

  # !! Note that `label_tag` is a Rails method, so we have to append and make exceptions
  def taxonworks_label_tag(label)
    return nil if label.nil?
    if label.is_generated?
      case label.type
      when 'Label::QrCode'
        return label_svg_tag(label)
      when 'Label::Code128'
        return label_code_128_tag(label)
      else
        return send('label_' + label.type.split('::').last.tableize.singularize + '_tag', label)
      end
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

  # Object is a Container
  # TODO: Not done
  def label_drawer_tag(label)
    o = label.label_object
    tag.span(
      tag.span(
        tag.span(o.taxonomy['order']&.upcase, class: 'drawer_order') +
        tag.span(o.id, class: 'drawer_taxon_name_id'),
        class: 'drawer_top'
      ) +
      "\n" +
      tag.span(
        'stub', class: 'drawer_bottom'
      ), class: 'foo')
  end

  # Object is a Container
  # TODO: Not done
  def label_slide_box_tag(label)
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

  # Object is a TaxonName
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
      ) +
      tag.div('', class: 'unit_tray_header1_footer'),
      class: 'unit_tray_header1')
  end

  # Object is a Container
  # TODO: Not done
  def label_vial_rack_horizontal_tag(label)
    o = label.label_object
    tag.span(
      tag.span(
        tag.span(o.taxonomy['order']&.upcase, class: 'vial_rack_order') +
        tag.span(o.taxonomy['family'], class: 'vial_rack_family'),
        class: 'vial_rack_top'
      ), class: 'foo')

    #  "\n" +
    #  tag.span( taxon_name_tag(o), class: 'vial_rack_species') # +
    # tag.span( o.cached_author_year, class: 'vial_rack_author_year') +
    # "\n" +
    # tag.span(
    #   tag.span(o.id, class: vial_rack_taxon_name_id) +
    #   tag.span('R', class: vial_rack_container_id)  # TODO: can we find this?
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
