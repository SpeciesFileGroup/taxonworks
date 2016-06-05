module Workbench::FormHelper

  def destroy_related_link(f, text: 'x')
    content_tag(:span, text, class: 'destroyable', 'data-object-name' => f.object_name) if !f.object.new_record? 
  end

  def lock_tag(locks, object_name, method)
    locked = locks.locked?(object_name, method)
    check_box_tag("locks[#{object_name}][#{method}]", "1", locked, class: (locked ? :locked : :unlocked)) + 
    label_tag("locks[#{object_name}][#{method}]",'', class: (locked ? :label_unlocked : :label_unlocked))
  end

end
