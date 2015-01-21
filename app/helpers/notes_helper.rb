module NotesHelper

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
    # new_object = Note.new(note_object_id:   f.object.id,
    #                                 note_object_type: f.object.class.base_class.name)
    # fields     = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
    #   render(association.to_s.singularize + "_fields", :f => builder)
    fields = f.fields_for(:notes, new_object, :child_index => 'new_notes') do |builder|
      render('notes/note_fields', :avf => builder)
    end
    # link_to(link_text, '', id: "#{association[0]}-add", onclick: "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
    # link_to(link_text, '', id: "#{association[0]}-add")
    # link_to(link_text, '', id: "#{association[0]}-add", fields: fields)
    link_to(link_text, '', class: 'note-add', association: 'notes', content: "#{fields}")
  end

  def add_note_link(object: object, attribute: nil)
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

  def note_tag(note)
    return nil if note.nil?
    note.text
  end
end
