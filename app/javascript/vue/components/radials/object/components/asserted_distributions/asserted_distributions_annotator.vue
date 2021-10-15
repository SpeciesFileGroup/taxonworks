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
        @lock="lockSource = $event"
        :display="displayLabel"/>
      <template v-if="asserted_distribution.id">
        <button
          v-if="editCitation"
          type="button"
          class="button normal-input button-submit"
          @click="createAsserted">Update
        </button>
        <button
          v-else
          type="button"
          class="button normal-input button-submit"
          @click="createAsserted">Create
        </button>
      </template>
      <display-list
        class="margin-medium-top"
        v-if="asserted_distribution.id"
        :list="asserted_distribution.citations"
        :edit="true"
        @edit="setEditCitation"
        @delete="removeCitation"
        label="citation_source_body"/>
      <div>
        <spinner
          v-if="!asserted_distribution.citations_attributes[0].source_id || asserted_distribution.id"
          :show-legend="false"
          :show-spinner="false"/>
        <geographic-area
          class="separate-bottom"
          @lock="lockGeo = $event"
          :created-list="list"
          :source-lock="lockSource"
          @select="asserted_distribution.geographic_area_id = $event; createAsserted()"/>
      </div>
    </div>
    <div class="horizontal-left-content">
      <map-component
        width="90%"
        height="300px"
        :zoom="2"
        :zoom-on-click="false"
        :geojson="shapes"/>
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
import DisplayList from 'components/displayList.vue'
import GeographicArea from './geographicArea.vue'
import SourcePicker from './sourcePicker.vue'
import Spinner from 'components/spinner.vue'
import MapComponent from 'components/georeferences/map.vue'
import { AssertedDistribution } from 'routes/endpoints'

export default {
  mixins: [CRUD, AnnotatorExtend],
  components: {
    Spinner,
    TableList,
    SourcePicker,
    DisplayList,
    GeographicArea,
    MapComponent
  },
  computed: {
    validateFields () {
      return this.asserted_distribution.geographic_area_id && this.asserted_distribution.source_id
    },
    splittedGlobalId () {
      const splitted = this.globalId.split('/')
      return splitted[splitted.length - 1]
    },
    filterList () {
      return this.list
    },
    existingArea () {
      return this.list.find(item => item.geographic_area_id === this.asserted_distribution.geographic_area_id && (item.is_absent === null ? false : item.is_absent) === (this.asserted_distribution.is_absent === undefined ? false : this.asserted_distribution.is_absent))
    },
    shapes () {
      return this.list.map(item => {
        const shape = item.geographic_area.shape
        shape.properties.is_absent = item.is_absent
        return shape
      })
    }
  },
  data () {
    return {
      asserted_distribution: this.newAsserted(),
      displayLabel: undefined,
      displayGeographic: undefined,
      editTitle: undefined,
      lockSource: false,
      lockGeo: false,
      editCitation: undefined,
      urlList: `${this.url}/${this.type}.json?geo_json=true`
    }
  },

  created () {
    this.asserted_distribution.otu_id = this.splittedGlobalId
  },

  methods: {
    setEditCitation(citation) {
      const data = {
        id: citation.id,
        is_absent: undefined,
        pages: citation.pages,
        source_id: citation.source_id,
        is_original: citation.is_original,
        citation_source_body: citation.citation_source_body
      }
      this.editCitation = citation
      this.$refs.source.setCitation(data)
    },

    createAsserted () {
      const saveRequest = !this.existingArea
        ? AssertedDistribution.create({ asserted_distribution: this.asserted_distribution })
        : AssertedDistribution.update(this.existingArea.id, { asserted_distribution: this.asserted_distribution })

      saveRequest.then(({ body }) => {
        TW.workbench.alert.create('Asserted distribution was successfully saved.', 'notice')
        this.addToList(body)
      })
    },

    removeCitation (item) {
      const asserted_distribution = {
        citations_attributes: [{
          id: item.id,
          _destroy: true
        }]
      }
      AssertedDistribution.update(this.asserted_distribution.id, { asserted_distribution }).then(({ body }) => {
        this.addToList(body)
      })
    },

    addToList (item) {
      const index = this.list.findIndex(ad => ad.id === item.id)

      if (!this.lockSource) {
        this.$refs.source.cleanInput()
      }

      this.editTitle = item.object_tag

      AssertedDistribution.find(item.id, { geo_json: true }).then(ad => {
        if (index > -1) {
          this.list[index] = ad.body
        } else {
          this.list.push(ad.body)
        }
        this.asserted_distribution = this.newAsserted()
      })
    },

    setDistribution (item) {
      this.asserted_distribution = this.newAsserted()
      this.editTitle = item.object_tag
      this.asserted_distribution.id = item.id
      this.asserted_distribution.citations = item.citations
      this.asserted_distribution.otu_id = item.otu_id
      this.asserted_distribution.geographic_area_id = item.geographic_area_id
      this.asserted_distribution.citations_attributes = [{
        id: undefined,
        source_id: undefined,
        pages: undefined,
        is_original: undefined
      }]
      this.editCitation = undefined
      this.$refs.source.cleanCitation()
    },

    newAsserted () {
      this.displayLabel = ''
      return { 
        id: undefined,
        otu_id: this.splittedGlobalId,
        geographic_area_id: this.lockGeo ? this.asserted_distribution.geographic_area_id : undefined,
        citations: [],
        citations_attributes: this.lockSource
          ? this.asserted_distribution.citations_attributes
          : [{
              source_id: undefined,
              pages: undefined,
              is_original: undefined
            }],
        is_absent: undefined
      }
    },

    setSource (source) {
      this.asserted_distribution.is_absent = source.is_absent
      this.asserted_distribution.citations_attributes[0].id = source.id
      this.asserted_distribution.citations_attributes[0].source_id = source.source_id
      this.asserted_distribution.citations_attributes[0].pages = source.pages
      this.asserted_distribution.citations_attributes[0].is_original = source.is_original
    }
  },
}
</script>
<style lang="scss">
  .radial-annotator {
    .biological_relationships_annotator {
      position: relative;
      overflow-y: scroll;

      .pages {
        width: 86px;
      }
      .asserted-map-link {
        position: absolute;
        right:0px;
      }
    }
  }
</style>