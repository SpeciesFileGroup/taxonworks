json.extract! news, :id, :type, :title, :body, :display_start, :display_end, :is_public, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at

json.updater news.updater.name
json.creator news.creator.name

json.current news.is_current?

json.body_html MARKDOWN_HTML.render(news.body).html_safe

json.url news_url(news, format: :json)
