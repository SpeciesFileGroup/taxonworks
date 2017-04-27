json.extract! @object, :id
json.global_id @object.metamorphosize.to_global_id.to_s
json.object_tag object_tag(@object)

%w{notes depictions confidences citations tags}.each do |a|

  if @object.send("has_#{a}?")
    json.set! a.to_sym do
      json.array! @object.send(a) do |annotation|
        json.partial! "/#{a}/attributes", a.singularize.to_sym => annotation
      end
    end
  end

end



