import RadialAnnotator from 'components/radials/annotator/annotator'
import OtuRadial from 'components/otu/otu'
import { Citation } from 'routes/endpoints'

export default {
  components: {
    RadialAnnotator,
    OtuRadial
  },
  props: {
    citation: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      pages: undefined,
      autoSave: undefined,
      time: 3000
    }
  },

  emits: ['delete'],

  methods: {
    createGlobalId (id) {
      return `gid://taxon-works/Protonym/${id}`
    },

    showObject () {
      return this.citation.citation_object.object_url
    },

    changePage () {
      if (this.autoSave) {
        clearTimeout(this.autoSave)
      }
      this.autoSave = setTimeout(() => {
        Citation.update(this.citation.id, { citation: this.citation }).then(response => {
          TW.workbench.alert.create('Citation was successfully updated.', 'notice')
        })
      }, this.time)
    },

    updateCitation () {
      Citation.update(this.citation.id, { citation: this.citation }).then(response => {
        TW.workbench.alert.create('Citation was successfully updated.', 'notice')
      })
    },

    updatePage () {
      if (this.autoSave) {
        clearTimeout(this.autoSave)
      }
      this.autoSave = setTimeout(() => {
        this.updateCitation()
      }, this.time)
    },

    removeMe () {
      if (window.confirm('You\'re about to delete this citation record. Are you sure want to proceed?')) {
        Citation.destroy(this.citation.id).then(() => {
          this.$emit('delete', this.citation)
          TW.workbench.alert.create('Citation was successfully destroyed.', 'notice')
        }, reject => {
          TW.workbench.alert.create('Citation was not destroyed, ' + reject.statusText, 'notice')
        })
      }
    }
  }
}