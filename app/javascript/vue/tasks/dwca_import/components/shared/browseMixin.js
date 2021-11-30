import { RouteNames } from 'routes/routes.js'
import ModalComponent from 'components/ui/Modal'

export default {
  components: {
    ModalComponent
  },
  props: {
    row: {
      type: Object,
      required: true
    }
  },
  computed: {
    importedObjects () {
      return this.row?.metadata?.imported_objects
    },
    importedErrors () {
      return this.row?.metadata?.error_data
    },
    importedCount () {
      return this.importedObjects ? Object.keys(this.importedObjects).length : 0
    }
  },
  data () {
    return {
      urlTask: {
        collection_object: (id) => `${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`,
        taxon_name: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
      },
      showModal: false,
      showErrors: false
    }
  },
  methods: {
    loadTask (type, object) {
      window.open(this.taskUrl(type, object), '_blank')
    },
    taskUrl (type, object) {
      return this.urlTask[type](object.id)
    },
    openModal () {
      this.showModal = true
    }
  }
}
