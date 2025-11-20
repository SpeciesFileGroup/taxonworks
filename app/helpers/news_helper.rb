module NewsHelper

  def news_tag(news)
    return nil if news.nil?
    news.title[0..30]
  end

  def label_for_news(news)
    return nil if news.nil?
    news.title[0..30]
  end

  def createable_news_types(user)
    a = News::PROJECT_TYPES.invert.transform_keys{|k| k.to_s.humanize}

    if user.is_administrator?
      b = News::ADMINISTRATION_TYPES.invert.transform_keys{|k| k.to_s.humanize}
      a.merge b 
    else
      a
    end
  end

end
