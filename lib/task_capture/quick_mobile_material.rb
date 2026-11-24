# Processes one capture request from a Mobile app for the Quick mobile
# material task: one CollectionObject stub, always with one Image, added
# to a Layout::Task as a LayoutItem::TaskItem.
#
# Never updates an existing record: existing CollectionObjects only ever
# receive new Images (Depiction + TaskItem creates).
#
# Resolution order, in one transaction:
# 1. retry: the Image (by fingerprint) is already in the Project
# 2. append: collection_object_id given
# 3. match: catalog_number given, and that CatalogNumber exists
# 4. create
#
# Current.user_id and Current.project_id must be set (by
# TaskTokenAuthentication), this never sets them.
#
# Claude Code (Opus 5.5) wrote > 50% of this class.
#
class TaskCapture::QuickMobileMaterial

  # Params this accepts from the Mobile app; ids that must match the token
  # (user_id, project_id, composition_id) are checked by the concern.
  PERMITTED_PARAMS = %i{image collection_object_id catalog_number text}.freeze

  # status: a Rack status symbol (:ok, :unprocessable_content)
  # body: the JSON response, errors only (no ids) on failure
  Response = Struct.new(:status, :body, keyword_init: true)

  # Ignored params are flagged on a row in the Task until this passes.
  IGNORED_LIFETIME = 1.day

  class Unprocessable < StandardError; end

  attr_reader :composition_id, :repository_id, :namespace_id

  attr_reader :image_upload, :collection_object_id, :catalog_number, :text

  attr_reader :ignored

  # [Array of String] non-fatal notes returned to the Mobile app
  attr_reader :warnings

  # @param composition_id [Integer] from the token
  # @param repository_id [Integer, nil] from the token settings
  # @param namespace_id [Integer, nil] from the token settings
  # @param params [Hash] from the Mobile app, see PERMITTED_PARAMS
  def initialize(composition_id:, repository_id: nil, namespace_id: nil, params: {})
    @composition_id = composition_id
    @repository_id = repository_id
    @namespace_id = namespace_id

    params = params.to_h.symbolize_keys
    @image_upload = params[:image]
    @collection_object_id = params[:collection_object_id].presence
    @catalog_number = params[:catalog_number].to_s.strip.presence
    @text = params[:text].to_s.strip.presence

    @ignored = []
    @warnings = []
  end

  # @return [Response]
  def call
    raise Unprocessable, 'image is required' unless uploaded_file?

    body = nil
    ApplicationRecord.transaction do
      body = duplicate || append || match || create
    end

    record_ignored(body[:composition_item_id]) if ignored.any?

    Response.new(status: :ok, body:)
  rescue Unprocessable => e
    failure(e.message)
  rescue ActiveRecord::RecordInvalid => e
    failure(*e.record.errors.full_messages)
  rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordNotUnique
    failure('the record could not be saved')
  end

  # Rails.cache, not a record: no capture request updates an existing record.
  # @return [String]
  def self.ignored_key(composition_item_id)
    "task_capture/quick_mobile_material/ignored/#{composition_item_id}"
  end

  # @return [Hash] composition_item_id => [String] params not applied
  def self.ignored_for(composition_item_ids)
    keys = composition_item_ids.index_by { |id| ignored_key(id) }
    Rails.cache.read_multi(*keys.keys).transform_keys { |k| keys[k] }
  end

  # @return [String] sensu Image#image_file_fingerprint
  def image_md5
    @image_md5 ||= Digest::MD5.file(image_upload.path).hexdigest
  end

  private

  def record_ignored(composition_item_id)
    key = self.class.ignored_key(composition_item_id)
    Rails.cache.write(key, (Array(Rails.cache.read(key)) | ignored), expires_in: IGNORED_LIFETIME)
  end

  def uploaded_file?
    image_upload.respond_to?(:path) && image_upload.path.present? && File.exist?(image_upload.path)
  end

  # Step 1
  def duplicate
    image = Image.where(project_id: Current.project_id, image_file_fingerprint: image_md5).first
    return nil if image.nil?

    item = task_items
      .joins("JOIN depictions d ON d.depiction_object_id = composition_items.composition_item_object_id AND d.depiction_object_type = 'CollectionObject'")
      .where(d: { image_id: image.id })
      .first

    raise Unprocessable, 'image is already in the project, but not in this composition' if item.nil?

    depiction = Depiction.find_by(image_id: image.id, depiction_object_type: 'CollectionObject', depiction_object_id: item.composition_item_object_id)
    success('duplicate', item.composition_item_object, image, depiction, item)
  end

  # Step 2
  def append
    return nil if collection_object_id.nil?

    co = CollectionObject.where(project_id: Current.project_id).find_by(id: collection_object_id)
    item = co && task_items.find_by(composition_item_object: co)
    raise Unprocessable, 'collection_object_id is not in this composition' if item.nil?

    if catalog_number
      cn = catalog_number_of(co)
      if cn.nil?
        ignored.push('catalog_number')
      elsif cn.identifier != catalog_identifier(namespace || cn.namespace) || (namespace_id && cn.namespace_id != namespace_id.to_i)
        raise Unprocessable, 'catalog_number differs from that of the collection object'
      end
    end

    ignored.push('text') if text

    image, depiction = depict(co)
    success('appended', co, image, depiction, item)
  end

  # Step 3
  def match
    return nil if catalog_number.nil?
    raise Unprocessable, 'catalog_number requires a namespace setting' if namespace_id.nil?

    cn = Identifier::Local::CatalogNumber.where(project_id: Current.project_id, namespace_id:, identifier: catalog_identifier(namespace)).first
    return nil if cn.nil?

    co = cn.identifier_object
    raise Unprocessable, "catalog_number belongs to a #{cn.identifier_object_type}, not a collection object" unless co.is_a?(CollectionObject)

    ignored.push('text') if text

    image, depiction = depict(co)
    item = task_items.find_by(composition_item_object: co) || add_item(co)
    success('matched', co, image, depiction, item)
  end

  # Step 4
  def create
    co = Specimen.create!(repository_id:, buffered_collecting_event: text)

    if catalog_number
      Identifier::Local::CatalogNumber.create!(identifier_object: co, namespace_id:, identifier: catalog_identifier(namespace))
    end

    image, depiction = depict(co)
    success('created', co, image, depiction, add_item(co))
  end

  # Image Step 1 excludes existing fingerprints; a concurrent identical
  # upload fails Image's uniqueness validation (422).
  def depict(co)
    image = Image.create!(image_file: image_upload)
    depiction = Depiction.create!(image:, depiction_object: co)
    [image, depiction]
  end

  def add_item(co)
    LayoutItem::TaskItem.create!(composition_id:, composition_item_object: co)
  end

  def namespace
    return nil if namespace_id.nil?
    @namespace ||= Namespace.find_by(id: namespace_id)
  end

  # The Mobile app sends the catalog number as read from the label, e.g.
  # "INHS 122345"; the Namespace (from the token settings) is split off,
  # leaving the CatalogNumber#identifier "122345". Memoized per Namespace,
  # so a warning is added at most once.
  # @return [String]
  def catalog_identifier(target_namespace)
    @catalog_identifiers ||= {}
    @catalog_identifiers[target_namespace&.id] ||= begin
      if target_namespace.nil? || target_namespace.is_virtual?
        catalog_number
      else
        priors = [target_namespace.verbatim_short_name, target_namespace.short_name, target_namespace.name]
        r = Utilities::CatalogNumbers.parse(catalog_number, namespaces: priors)

        if r[:prior]
          r[:identifier]
        else
          if r[:namespace]
            warnings.push("catalog_number '#{catalog_number}' may include a namespace ('#{r[:namespace]}') other than '#{target_namespace.short_name}', it was used as is")
          end
          catalog_number
        end
      end
    end
  end

  def task_items
    LayoutItem::TaskItem.where(composition_id:)
  end

  def catalog_number_of(co)
    Identifier::Local::CatalogNumber.where(identifier_object: co).order(:position).first
  end

  def success(result, co, image, depiction, item)
    cn = catalog_number_of(co)

    {
      result:,
      collection_object_id: co.id,
      catalog_number: cn && { identifier_id: cn.id, namespace_id: cn.namespace_id, identifier: cn.identifier },
      image_id: image.id,
      depiction_id: depiction&.id,
      composition_item_id: item.id,
      image_md5: image.image_file_fingerprint,
      ignored:,
      warnings:
    }
  end

  def failure(*errors)
    Response.new(status: :unprocessable_content, body: { errors: errors.flatten.compact.presence || ['unprocessable'] })
  end

end
