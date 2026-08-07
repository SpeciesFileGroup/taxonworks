json.merge! Topic.joins(:contents).where(project_id: sessions_current_project_id).order(:name).inject({}){|hsh, t|
  hsh.merge!(t.name => {
    topic_id: t.id,
    published: t.public_contents.count, 
    unpublished: Content.left_joins(:public_content).where(contents: {topic_id: t.id}, public_content: {id: nil}).count
  });
  hsh
}
