module FactoryProjectHelpers
  module_function

  def assign_project_scoped(record, association_name, factory_name)
    return if record.public_send(association_name).present?

    record.public_send(
      :"#{association_name}=",
      FactoryBot.create(factory_name, project_id: record.project_id)
    )
  end
end
