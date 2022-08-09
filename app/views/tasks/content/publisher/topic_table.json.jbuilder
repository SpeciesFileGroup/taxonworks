json.merge! Content.where(project_id: sessions_current_project_id, topic_id: params[:topic_id] ).order('contents.id DESC').all.inject([]){|ary, c|
  ary.push(
    id: c.id,
    text: c.text,
    public_text: c.public_content&.text,
    otu: otu_tag(c.otu),
    published: c.is_published?,
    out_of_date: !c.public_content&.is_current?,
    version: c.versions.count);
    ary 
}
