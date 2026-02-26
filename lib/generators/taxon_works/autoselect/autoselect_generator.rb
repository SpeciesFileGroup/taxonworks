# lib/generators/taxon_works/autoselect/autoselect_generator.rb
#
# Generator for TaxonWorks Autoselect stubs.
require 'rails/generators'

# Usage:
#   rails generate taxon_works:autoselect <model_name> [level_name ...] [--fast] [--no-example]
#
# Examples:
#   rails generate taxon_works:autoselect taxon_name --fast catalog_of_life
#   rails generate taxon_works:autoselect otu catalog_of_life
#
class TaxonWorks::AutoselectGenerator < Rails::Generators::Base
  desc 'Stubs out an Autoselect for a TaxonWorks model'

  source_root File.expand_path('../templates', __FILE__)

  argument :model_name, type: :string, required: true,
    banner: '<model_name (snake_case)>'

  argument :level_names, type: :array, required: false, default: [],
    banner: '<level_name ...>'

  class_option :fast, type: :boolean, default: false,
    desc: 'Generate a fast level stub (direct Arel on cached field)'

  class_option :no_example, type: :boolean, default: false,
    desc: 'Skip adding a placeholder to the Autoselect Playground debugging task'

  # Methods execute in declaration order (Thor convention)

  def validate_arguments
    unless model_name.match?(/\A[a-z][a-z_]*\z/)
      puts Rainbow("ERROR: model_name '#{model_name}' must be snake_case (lowercase letters and underscores only)").red
      abort
    end
  end

  def create_autoselect
    template 'autoselect.rb.tt',
      "lib/autoselect/#{model_name}/autoselect.rb"
  end

  def create_operators_stub
    template 'operators.rb.tt',
      "lib/autoselect/#{model_name}/operators.rb"
  end

  def create_fast_level
    return unless options[:fast]
    template 'levels/fast.rb.tt',
      "lib/autoselect/#{model_name}/levels/fast.rb"
  end

  def create_custom_levels
    custom_level_names.each do |custom_level_name|
      @current_level_name = custom_level_name
      template 'levels/custom.rb.tt',
        "lib/autoselect/#{model_name}/levels/#{custom_level_name}.rb"
    end
  end

  def inject_route
    route_file = 'config/routes/data.rb'
    return unless File.exist?(File.join(destination_root, route_file))

    route_line = "    get :autoselect, defaults: { format: :json }\n"
    # Find the collection do block within the model's resources block and inject after it opens.
    # Regex anchored to the specific model to avoid matching other resources blocks.
    inject_into_file route_file,
      route_line,
      after: /resources :#{model_name.pluralize} do.*?collection do\n/m
  end

  def inject_controller_action
    controller_file = "app/controllers/#{model_name.pluralize}_controller.rb"
    return unless File.exist?(File.join(destination_root, controller_file))

    action_code = <<~RUBY

      # GET /#{model_name.pluralize}/autoselect
      def autoselect
        render json: ::Autoselect::#{model_class_name}::Autoselect.new(
          term: params[:term],
          level: params[:level],
          project_id: sessions_current_project_id,
          user_id: sessions_current_user_id,
          **autoselect_params
        ).response
      end
    RUBY

    inject_into_file controller_file,
      action_code,
      before: /^  private\b/

    params_code = <<~RUBY

        def autoselect_params
          params.permit(
            # TODO: add model-specific permitted autoselect params here
          ).to_h.symbolize_keys
        end
    RUBY

    inject_into_file controller_file,
      params_code,
      after: /^  private\n/
  end

  def update_debugging_task
    return if options[:no_example]

    app_vue = 'app/javascript/vue/tasks/debugging/autoselects/app.vue'
    return unless File.exist?(app_vue)

    comment_line = "      // { url: '/#{model_name.pluralize}/autoselect', param: '#{model_name}_id', label: '#{model_class_name}' },"

    inject_into_file app_vue,
      "\n#{comment_line}",
      after: 'const registeredModels = ref(['
  end

  private

  def model_class_name
    model_name.camelize
  end

  # Custom (non-built-in) level names from arguments, excluding operator specs (contain ':')
  def custom_level_names
    level_names.reject { |l| l.include?(':') }
  end

  # Ordered list of level class names for the generated autoselect.rb
  def level_class_names
    names = []
    names << 'Fast' if options[:fast]
    names << 'Smart'
    custom_level_names.each { |l| names << l.camelize }
    names
  end

end
