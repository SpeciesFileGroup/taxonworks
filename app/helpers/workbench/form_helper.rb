module Workbench::FormHelper

  def destroy_related_link(f, text: 'x')
    content_tag(:span, text, class: 'destroyable', 'data-object-name' => f.object_name) if !f.object.new_record? 
  end

  def lock_tag(locks, object_name, method)

  	if (defined? locks.locked) then
      locked = locks.locked?(object_name, method)
  	else
  		locked = false
  	end

    name = "locks[#{object_name}][#{method}]"
    check_box_tag(name, "1", locked, class: (locked ? :locked : :unlocked)) + 
    label_tag(name,'', class: (locked ? :label_unlocked : :label_unlocked))
  end

end
