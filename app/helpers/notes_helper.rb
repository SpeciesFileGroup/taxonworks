module NotesHelper

  def note_tag(note)
    return nil if note.nil?

    # Note that markdown standard includes a p.  It is upto the style class
    # to remove/hide this class, do NOT replace it here or post-process it (for the time being).
    content_tag(:div, MARKDOWN_HTML.render(note.text).html_safe, class: [:annotation__note])
  end
  alias_method :note_annotation_tag, :note_tag 

  def note_list_tag(object)
    return nil unless object.has_notes? && object.notes.any?
    content_tag(:h3, 'Notes') +
      content_tag(:ul, class: 'annotations__note_list') do
      object.notes.collect{|a| content_tag(:li, note_annotation_tag(a)) }.join.html_safe 
    end
  end

  def note_autocomplete_tag(note, term)
    return nil if note.nil?
    a = [
      content_tag(:span, mark_tag(note.text, term), class: [:regular_type]), 
      content_tag(:div, object_tag(note.note_object), class: [:feedback, 'feedback-secondary', 'feedback-thin'] ),
      content_tag(:span, note.note_object_type, class: [:feedback, 'feedback-info', 'feedback-thin'] ),
    ].compact.join('&nbsp;').html_safe
  end

  def link_to_destroy_note(link_text, note)
    link_to(link_text, '', class: 'note-destroy', note_id: note.id)
  end

  def link_to_edit_note(link_text, note)
    link_to(link_text, '', class: 'note-edit', note_id: note.id)
  end

  def link_to_add_note(link_text, f)
    new_object = f.object.class.reflect_on_association(:notes).klass.new({note_object_type: f.object.class.base_class.name,
                                                                          note_object_id: f.object.id,
                                                                          note_object_attribute: 'name'})
    fields = f.fields_for(:notes, new_object, child_index: 'new_notes') do |builder|
      render('notes/note_fields', avf: builder)
    end
    link_to(link_text, '', class: 'note-add', association: 'notes', content: "#{fields}")
  end

  def add_note_link(object: nil, attribute: nil)
    link_to('Add note', new_note_path(note: {
                                          note_object_type: object.class.base_class.name,
                                          note_object_id: object.id,
                                          note_object_attribute: attribute})) if object.has_notes?
  end

  def edit_note_link(note)
    edit_object_link(note)
    # link_to('Edit', edit_note_path(note))
  end

  def destroy_note_link(note)
    destroy_object_link(note)
  end


  def note_link(note)
    return nil if note.nil?
    link_to(note_tag(note).html_safe, metamorphosize_if(note.note_object)  )
  end

  def notes_search_form
    render('/notes/quick_search_form')
  end

   # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def notes_recent_objects_partial
    true 
  end

end
