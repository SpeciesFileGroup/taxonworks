module Workbench::FormHelper

  def destroy_related_link(f, text: 'x')
    content_tag(:span, text, class: 'destroyable', 'data-object-name' => f.object_name) if !f.object.new_record? 
  end

  # @param locks [Field::Locks] 
  # @param object_name [String, Symbol] the object 
  # @param method [String, Symbo] the method  
  # @return [html] a check box and label, styled as SVG icons
  def lock_tag(locks, object_name, method)
    locked = locks.locked?(object_name, method)
    name = "locks[#{object_name}][#{method}]"
    check_box_tag(name, "1", locked, class: (locked ? :locked : :unlocked)) + 
    label_tag(name,'', class: (locked ? :label_unlocked : :label_unlocked))
  end

  def increment_tag(object_name, method)
    name = "locks[#{object_name}][#{method}]"
    check_box_tag(name, "1", false, class: :increment) + 
    label_tag(name,'', class: :label_increment)
  end  

end
