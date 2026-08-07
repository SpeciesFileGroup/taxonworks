json.extract! news, :id, :type, :title, :body, :display_start, :display_end, :project_id, :created_at, :updated_at

json.current news.is_current?

json.updater news.updater.name
json.creator news.creator.name

json.body_html MARKDOWN_HTML.render(news.body).html_safe

json.url news_url(news, format: :json)
