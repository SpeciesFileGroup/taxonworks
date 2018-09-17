<template>
  <tr>
    <td>
      <input
        type="text"
        @input="changePage"
        v-model="citation.pages">
    </td>
    <td v-html="citation.citation_object.object_tag"/>
    <td>
      <radial-annotator :global-id="citation.citation_object.global_id" />
    </td>
    <td>
      <otu-radial
        :taxon-id="citation.citation_object_id"
        :redirect="false"/>
    </td>
    <td><span class="button circle-button btn-delete" @click="removeMe()"/></td>
  </tr>
</template>

<script>

import RadialAnnotator from '../../../../../components/annotator/annotator'
import OtuRadial from '../../../../../components/otu/otu'

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
    changePage() {
      let that = this;
      if(this.autoSave) {
        clearTimeout(this.autoSave)
      }
      this.autoSave = setTimeout(() => {
        that.$http.patch('/citations/' + this.citation.id  + '.json', { citation: this.citation }).then(response => {
          TW.workbench.alert.create('Citation was successfully updated.', 'notice')
        })
        // that.$http.post('/citations/.json', { citation: this.citation }).then(response => {
        //   TW.workbench.alert.create('Citation was successfully created.', 'notice')
        // })     // above block for CREATE-ing new citations on page edit
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
</script>