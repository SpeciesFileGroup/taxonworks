json.validated @object.soft_validations.validated
json.fixes_run @object.soft_validations.fixes_run

json.instance do
  json.id @object.id
  json.global_id @object.to_global_id.to_s
  json.klass @object.class.name
end

json.soft_validations do
  json.array!(@object.soft_validations.soft_validations) do |v|
    json.description v.description
    json.fixable !v.fix.nil?
    json.attribute v.attribute
    json.fixed v.fixed
    json.message v.message
    json.success_message v.success_message
    json.failure_message v.failure_message
    json.soft_validation_method v.soft_validation_method
    json.resolution v.resolution.collect{|r| send("#{r}_path", "#{@object.class.base_class.name.underscore}_id": @object.id , id: @object.id)}
  end
end
