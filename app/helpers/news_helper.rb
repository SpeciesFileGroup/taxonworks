module NewsHelper

  def news_tag(news)
    return nil if news.nil?
    news.title[0..30]
  end

  def label_for_news(news)
    return nil if news.nil?
    news.title[0..30]
  end

end
