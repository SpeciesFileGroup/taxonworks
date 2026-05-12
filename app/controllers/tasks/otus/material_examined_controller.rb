class Tasks::Otus::MaterialExaminedController < ApplicationController
  include TaskControllerConfiguration

  MAX_OTUS = 100

  def index
  end

  # POST /tasks/otus/material_examined/preview.json
  def preview
    otu_ids = Array.wrap(params[:otu_id]).first(MAX_OTUS).map(&:to_i).uniq.compact
    order   = parse_order_param
    todo    = ActiveModel::Type::Boolean.new.cast(params[:todo])

    results = otu_ids.map do |otu_id|
      otu      = ::Otu.where(project_id: sessions_current_project_id).find(otu_id)
      renderer = ::Export::Helpers::MaterialExamined.renderer_for_otu(otu, order:, todo:)
      text     = renderer.render
      html     = text.empty? ? '' : MARKDOWN_HTML.render(text)

      todo_items = renderer.todo_occurrence_ids.uniq.filter_map do |occ_id|
        aug = renderer.augmentations[occ_id]
        next unless aug&.dig(:edit_link)
        { label: aug[:label], url: aug[:edit_link] }
      end

      { otu_id: otu.id, label: helpers.label_for_otu(otu), text:, html:, todo_items: }
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
