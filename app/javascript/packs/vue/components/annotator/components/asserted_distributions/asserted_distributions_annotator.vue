<template>
  <div class="biological_relationships_annotator">

    <div>
      <source-picker @create="setSource"/>
      <div>
        <spinner
          v-if="!asserted_distribution.origin_citation_attributes.source_id"
          :show-legend="false"
          :show-spinner="false"/>
        <geographic-area 
          class="separate-bottom"
          :created-list="list"
          @select="asserted_distribution.geographic_area_id = $event; createAsserted()"/>
      </div>
    </div>
    <table-list 
      class="separate-top"
      :header="['Geographic area', 'Absent', '']"
      :attributes="[['geographic_area', 'name'], 'is_absent']"
      :list="filterList"
      @delete="removeItem"/>
  </div>
</template>
<script>

  import CRUD from '../../request/crud.js'
  import AnnotatorExtend from '../annotatorExtend.js'
  import TableList from '../../../table_list.vue'
  import GeographicArea from './geographicArea.vue'
  import SourcePicker from './sourcePicker.vue'
  import Spinner from '../../../spinner.vue'

  export default {
    mixins: [CRUD, AnnotatorExtend],
    components: {
      Spinner,
      TableList,
      SourcePicker,
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
      filterList() {
        let newList = []
        let that = this;
        if(this.asserted_distribution.origin_citation_attributes.source_id) {
          this.list.forEach(item => {
            if(item.source.id == that.asserted_distribution.origin_citation_attributes.source_id) {
              newList.push(item)
            }
          })
          return newList
        }
        else {
          return this.list
        }
      }
    },
    data() {
      return {
        asserted_distribution: this.newAsserted()
      }
    },
    mounted() {
      this.asserted_distribution.otu_id = this.splittedGlobalId
    },
    methods: {
      createAsserted() {
        this.create('/asserted_distributions.json', { asserted_distribution: this.asserted_distribution }).then(response => {
          this.list.push(response.body)
        })
      },
      newAsserted() {
        return { 
          otu_id: this.splittedGlobalId,
          geographic_area_id: undefined,
          origin_citation_attributes: {
            source_id: undefined
          },
          is_absent: undefined
        }
      },
      setSource(source) {
        this.asserted_distribution.origin_citation_attributes.source_id = source.source_id
        this.asserted_distribution.is_absent = source.is_absent
      }
    },
  }
</script>
<style type="text/css" lang="scss">
  .radial-annotator {
    .biological_relationships_annotator {
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
    }
  }
</style>