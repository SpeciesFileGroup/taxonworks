class Tasks::Otus::MaterialExaminedController < ApplicationController
  include TaskControllerConfiguration

  MAX_OTUS = 100

  def index
  end

  # POST /tasks/otus/material_examined/preview.json
  def preview
    otu_ids = params[:otu_id].to_a.first(MAX_OTUS).map(&:to_i).uniq.compact
    order   = parse_order_param

    results = otu_ids.map do |otu_id|
      otu = ::Otu.where(project_id: sessions_current_project_id).find(otu_id)
      text = ::Export::Helpers::MaterialExamined.render_for_otu(otu, order:)
      html = text.empty? ? '' : MARKDOWN_HTML.render(text)
      { otu_id: otu.id, label: helpers.label_for_otu(otu), text:, html: }
    end

    render json: { results: }
  end

  private

  VALID_ORDER_KEYS = ::Utilities::MaterialExamined::LOOP_VARIABLES.keys.map(&:to_s).freeze

  def parse_order_param
    raw = params[:order].to_a.map(&:to_s)
    # 'identifier' from the UI represents the identifier_namespace+identifier pair.
    expanded = raw.flat_map { |k| k == 'identifier' ? %w[identifier_namespace identifier] : k }
    valid = expanded.select { |k| VALID_ORDER_KEYS.include?(k) }.map(&:to_sym)
    valid.any? ? valid : ::Utilities::MaterialExamined::DEFAULT_ORDER
  end

end
