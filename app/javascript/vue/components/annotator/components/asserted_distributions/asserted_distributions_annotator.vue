<template>
  <div class="biological_relationships_annotator">
    <div>
      <div
        class="flex-separate"
        v-if="asserted_distribution.id">
        <h4
          class="separate-bottom"
          v-html="editTitle"/>
        <span
          data-icon="reset"
          @click="asserted_distribution = newAsserted()"/>
      </div>
      <source-picker
        @create="setSource"
        ref="source"
        :display="displayLabel"/>
      <button
        type="button"
        class="button normal-input button-submit"
        v-if="asserted_distribution.id"
        @click="createAsserted">Create
      </button>
      <display-list
        v-if="asserted_distribution.id"
        :list="asserted_distribution.citations"
        @delete="removeCitation"
        label="object_tag"/>
      <div>
        <spinner
          v-if="!asserted_distribution.citations_attributes[0].source_id || asserted_distribution.id"
          :show-legend="false"
          :show-spinner="false"/>
        <geographic-area 
          class="separate-bottom"
          :created-list="list"
          @select="asserted_distribution.geographic_area_id = $event; createAsserted()"/>
      </div>
    </div>
    <div>
      <a 
        class="asserted-map-link"
        :href="`/tasks/gis/otu_distribution_data/${metadata.object_id}`"
        target="blank">Map</a>
    </div>
    <table-list 
      class="separate-top"
      :header="['Geographic area', 'Absent', '']"
      :attributes="[['geographic_area', 'name'], 'is_absent']"
      :edit="true"
      @edit="setDistribution"
      :list="filterList"
      @delete="removeItem"/>
  </div>
</template>
<script>

  import CRUD from '../../request/crud.js'
  import AnnotatorExtend from '../annotatorExtend.js'
  import TableList from './table.vue'
  import DisplayList from '../../../displayList.vue'
  import GeographicArea from './geographicArea.vue'
  import SourcePicker from './sourcePicker.vue'
  import Spinner from '../../../spinner.vue'

  export default {
    mixins: [CRUD, AnnotatorExtend],
    components: {
      Spinner,
      TableList,
      SourcePicker,
      DisplayList,
      GeographicArea
    },
    computed: {
      validateFields() {
        return this.asserted_distribution.geographic_area_id && this.asserted_distribution.source_id
      },
      splittedGlobalId() {
        let splitted = this.globalId.split('/')
        return splitted[splitted.length-1]
      },
      idIndex() {
        return this.list.findIndex(item => item.id === this.asserted_distribution.id);
      },
      filterList() {
        let newList = []
        let that = this;

        if(this.asserted_distribution.citations_attributes[0].source_id) {
          this.list.forEach(item => {
            if(item.citations.find(citation => { 
                return citation.source_id == that.asserted_distribution.citations_attributes[0].source_id 
              })) {
              newList.push(item)
            }
          })
          return newList
        }
        else {
          return this.list
        }
      },
      existingArea() {
        return this.list.find(item => { return item.geographic_area_id == this.asserted_distribution.geographic_area_id })
      }
    },
    data() {
      return {
        asserted_distribution: this.newAsserted(),
        displayLabel: undefined,
        displayGeographic: undefined,
        editTitle: undefined
      }
    },
    mounted() {
      this.asserted_distribution.otu_id = this.splittedGlobalId
    },
    methods: {
      createAsserted() {
        if(!this.existingArea) {
          this.asserted_distribution.citations_attributes[0]['is_original'] = true
          this.create('/asserted_distributions.json', { asserted_distribution: this.asserted_distribution }).then(response => {
            this.addToList(response.body)
          })
        }
        else {
          this.asserted_distribution['id'] = this.existingArea.id
          this.update(`/asserted_distributions/${this.existingArea.id}.json`, { asserted_distribution: this.asserted_distribution }).then(response => {
            this.addToList(response.body)
          })          
        }
      },
      removeCitation(item) {
        let data = { 
          asserted_distribution: {
            citations_attributes: [{
              id: item.id,
              _destroy: true
            }]
          }
        }
        this.update(`/asserted_distributions/${this.asserted_distribution.id}.json`, data).then(response => {
          this.addToList(response.body)
        })
      },
      addToList(item) {
        this.editTitle = item.object_tag
        this.$refs.source.cleanInput()
        if(this.idIndex > -1) {
          this.$set(this.list, this.idIndex, item)
        }
        else {
          this.list.push(item)
        }
        this.asserted_distribution = this.newAsserted()
      },
      setDistribution(item) {
        this.asserted_distribution = this.newAsserted()
        this.editTitle = item.object_tag
        this.asserted_distribution.id = item.id
        this.asserted_distribution.citations = item.citations
        this.asserted_distribution.otu_id = item.otu_id
        this.asserted_distribution.geographic_area_id = item.geographic_area_id
      },
      newAsserted() {
        this.displayLabel = ''
        return { 
          id: undefined,
          otu_id: this.splittedGlobalId,
          geographic_area_id: undefined,
          citations: [],
          citations_attributes: [{
            source_id: undefined
          }],
          is_absent: undefined
        }
      },
      setSource(source) {
        this.asserted_distribution.citations_attributes[0].source_id = source.source_id
        this.asserted_distribution.is_absent = source.is_absent
      }
    },
  }
</script>
<style lang="scss">
  .radial-annotator {
    .biological_relationships_annotator {
      position: relative;
      overflow-y: scroll;
      button {
        min-width: 100px;
      }
      .switch-radio {
        label {
          min-width: 95px;
        }
      }
      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
      .pages {
        width: 86px;
      }
      .vue-autocomplete-input, .vue-autocomplete {
        width: 376px;
      }
      .asserted-map-link {
        position: absolute;
        right:0px;
      }
    }
  }
</style>