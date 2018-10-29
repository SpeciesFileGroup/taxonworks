import RadialAnnotator from 'components/annotator/annotator'
import OtuRadial from 'components/otu/otu'

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
  methods: {
    createGlobalId(id) {
      return `gid://taxon-works/Protonym/${id}`
    },
    showObject() {
      window.open(this.citation.citation_object.object_url, '_blank');
    },
    changePage() {
      let that = this;
      if(this.autoSave) {
        clearTimeout(this.autoSave)
      }
      this.autoSave = setTimeout(() => {
        that.$http.patch('/citations/' + this.citation.id  + '.json', { citation: this.citation }).then(response => {
          TW.workbench.alert.create('Citation was successfully updated.', 'notice')
        })
      }, this.time)
    },
    updateCitation() {
      this.$http.patch('/citations/' + this.citation.id + '.json', {citation: this.citation}).then(response => {
        TW.workbench.alert.create('Citation was successfully updated.', 'notice')
      })
    },
    updatePage() {
      let that = this;
      if (this.autoSave) {
        clearTimeout(this.autoSave)
      }
      this.autoSave = setTimeout(() => {
        that.updateCitation()
      }, this.time)
    },
    removeMe() {
      if(window.confirm(`You're about to delete this citation record. Are you sure want to proceed?`)) {
        this.$http.delete('/citations/' + this.citation.id + '.json').then(response => {
          this.$emit('delete', this.citation);
          TW.workbench.alert.create('Citation was successfully destroyed.', 'notice')
        }, reject => {
          TW.workbench.alert.create('Citation was not destroyed, ' + reject.statusText, 'notice')
        })
      }
    }
  }
}