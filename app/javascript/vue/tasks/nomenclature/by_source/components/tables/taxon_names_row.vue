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
      <span 
        v-if="isInvalid"
        data-icon="warning"
        title="Invalid"/>
      <span>
        <a
          v-html="citation.citation_object.object_tag"
          @click="showObject()"/> 
        {{ legend }}
      </span>
    </td>
    <td>
      <span v-html="citation.citation_object.type"/>
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
    data() {
      return {
        pages: undefined,
        autoSave: undefined,
        time: 3000,
        legend: '',
        nameStatus: ''
      }
    },
    computed: {
      isInvalid() {
        return (this.nameStatus == 'invalid')
      }
    },
    mounted() {
      this.nameAuthorYear();
      this.nameValidity();
    },
    methods: {
      showObject() {
        window.open('/tasks/nomenclature/browse/' + this.citation.citation_object_id, '_blank');
      },
      nameAuthorYear() {
          let taxon = this.citation.citation_object;
          let authorYear = ' ' + taxon.cached_author_year;
          if (taxon.cached_author_year == null) {
            authorYear = '';
          }
        this.legend = authorYear;
        },
      nameValidity() {
        let taxon = this.citation.citation_object;
        this.nameStatus = (taxon.id == taxon.cached_valid_taxon_name_id) ? 'valid' : 'invalid';
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
    width: 80px;
  }
  .validity {
    width: 40px;
  }
</style>