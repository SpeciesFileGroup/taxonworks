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

  def closed_news_ids
    return [] unless cookies[:closed_news]

    JSON.parse(cookies[:closed_news]) rescue []
  end

  def system_news_bars
    @system_news_bars ||= News.administration
      .current
      .where.not(id: closed_news_ids)
      .order(:display_start)
  end

  def closable_news?(news)
    news.type != 'News::Administration::Warning'
  end

  def css_class_for_news(news)
    case news.type
      
    when 'News::Administration::Warning'
      'news-bar-warning'
    when 'News::Administration::Notice'
      'news-bar-notice'
    when 'News::Administration::BlogPost'
      'news-bar-info'
    else
      'news-bar-default'
    end
  end


end
