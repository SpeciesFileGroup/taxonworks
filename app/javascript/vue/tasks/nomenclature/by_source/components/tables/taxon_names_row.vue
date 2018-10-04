<template>
  <tr>
    <td>
      <input
        class="pages"
        type="text"
        placeholder="Pages"
        @input="changePage"
        v-model="citation.pages">
    </td>
    <td>
      <span>
        <a
          v-html="citation.citation_object.object_tag"
          @click="showObject()"/> 
        {{ legend }}
      </span>
    </td>
    <td>
      <radial-annotator :global-id="citation.citation_object.global_id"/>
    </td>
    <td>
      <otu-radial
        :taxon-id="citation.citation_object_id"
        :redirect="false"/>
    </td>
    <td>
      <span
        class="button circle-button btn-delete"
        @click="removeMe()"/>
    </td>
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
    data() {
      return {
        pages: undefined,
        autoSave: undefined,
        time: 3000,
        legend: '' // <---- Making a data property will make reactive to the template. So when this value changes the template will be rendered again
      }
    },
    mounted() {
      //Rich, this will make the call to retrieve the information when the component is mounted
      this.getNameData()
    },
    methods: {
      showObject() {
        window.open('/tasks/nomenclature/browse/' + this.citation.citation_object_id, '_blank');
      },
      getNameData() {
        let legend = 'invalid';
        // Removed the line to retrieve the id. The object already have object_url.
        this.$http.get(this.citation.citation_object.object_url).then(response => {
          let taxon = response.body
          legend = ' ' + taxon.rank // This will override 'invalid' always
          let invalid = (taxon.id != taxon.cached_valid_taxon_name_id)
          if (invalid && (taxon.type == 'Combination')) {
            legend = ' combination' // Looking this line and the space at the start, the rank is not missing here? not sure if that was the idea.
          }
          let authorYear = (taxon.cached_author_year == null) ? ' ' : ' ' + taxon.cached_author_year
          legend = authorYear + legend
          this.legend = legend
        })
      },
      changePage() {
        let that = this;
        if (this.autoSave) {
          clearTimeout(this.autoSave)
        }
        this.autoSave = setTimeout(() => {
          that.$http.patch('/citations/' + this.citation.id + '.json', {citation: this.citation}).then(response => {
            TW.workbench.alert.create('Citation was successfully updated.', 'notice')
          })
        }, this.time)
      },
      removeMe() {
        if (window.confirm(`You're about to delete this citation record. Are you sure want to proceed?`)) {
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
<style lang="scss" module>
  .pages {
    width: 140px;
  }
</style>