json.lead do
  json.partial! 'attributes', lead: @lead
end

json.future @future

if @lead_item_otus[:parent].count > 0
  json.print_key MARKDOWN_HTML.render(
    print_key_markdown(@lead.root, lead_items: true)
  )
end
