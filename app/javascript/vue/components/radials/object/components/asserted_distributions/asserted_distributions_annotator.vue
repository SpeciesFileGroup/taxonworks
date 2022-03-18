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
          @click="resetForm()"/>
      </div>
      <source-picker
        v-model="citation"
        v-model:absent="asserted_distribution.is_absent"
        ref="source"
        @lock="lock.source = $event"
      />
      <button
        v-if="asserted_distribution.id"
        type="button"
        class="button normal-input button-submit"
        @click="saveAssertedDistribution"
      >
        {{ editCitation ? 'Update' : 'Create' }}
      </button>
      <display-list
        v-if="asserted_distribution.id"
        edit
        class="margin-medium-top"
        label="citation_source_body"
        :list="asserted_distribution.citations"
        @edit="setCitation"
        @delete="removeCitation"
      />
      <div>
        <spinner
          v-if="!citation.source_id || asserted_distribution.id"
          :show-legend="false"
          :show-spinner="false"
        />
        <geographic-area
          class="separate-bottom"
          :source-lock="lock.source"
          @select="asserted_distribution.geographic_area_id = $event; saveAssertedDistribution()"
        />
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
      edit
      :list="list"
      @edit="setDistribution"
      @delete="removeItem"
    />
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
import { addToArray } from 'helpers/arrays.js'
import { AssertedDistribution } from 'routes/endpoints'

const EXTEND_PARAMS = {
  embed: ['shape'],
  extend: [
    'geographic_area',
    'geographic_area_type',
    'parent', 'citations',
    'source'
  ]
}

const makeEmptyCitation = () => ({
  id: undefined,
  source_id: undefined,
  pages: undefined,
  is_original: undefined
})

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

    existingArea () {
      return this.list.find(item =>
        item.geographic_area_id === this.asserted_distribution.geographic_area_id &&
        (item.is_absent === null ? false : item.is_absent) === (this.asserted_distribution.is_absent === null ? false : this.asserted_distribution.is_absent))
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
      asserted_distribution: {},
      editTitle: undefined,
      editCitation: undefined,
      loadOnMounted: false,

      citation: makeEmptyCitation(),

      lock: {
        geo: false,
        source: false
      }
    }
  },

  created () {
    this.asserted_distribution = this.newAsserted()
    AssertedDistribution.where({
      otu_id: this.metadata.object_id,
      ...EXTEND_PARAMS
    }).then(({ body }) => {
      this.list = body
    })
    this.asserted_distribution.otu_id = this.metadata.object_id
  },

  methods: {
    setCitation (citation) {
      this.citation = {
        id: citation.id,
        pages: citation.pages,
        source_id: citation.source_id,
        is_original: citation.is_original
      }
      this.editCitation = citation
    },

    saveAssertedDistribution () {
      const params = {
        asserted_distribution: {
          ...this.asserted_distribution,
          citations_attributes: [this.citation]
        },
        ...EXTEND_PARAMS
      }

      const saveRequest = !this.existingArea
        ? AssertedDistribution.create(params)
        : AssertedDistribution.update(this.existingArea.id, params)

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

      AssertedDistribution.update(
        this.asserted_distribution.id, {
          asserted_distribution,
          ...EXTEND_PARAMS
        })
        .then(({ body }) => {
          this.addToList(body)
        })
    },

    addToList (item) {
      this.editTitle = item.object_tag

      AssertedDistribution.find(item.id, EXTEND_PARAMS).then(({ body }) => {
        addToArray(this.list, body)
        this.resetForm()
      })
    },

    setDistribution (item) {
      this.resetForm()
      this.editTitle = item.object_tag
      this.asserted_distribution = {
        id: item.id,
        citations: item.citations,
        otu_id: item.otu_id,
        is_absent: item.is_absent,
        geographic_area_id: item.geographic_area_id,
      }

      this.editCitation = undefined
    },

    newAsserted () {
      return {
        id: undefined,
        otu_id: this.metadata.object_id,
        geographic_area_id: this.lock.geo ? this.asserted_distribution.geographic_area_id : undefined,
        citations: [],
        is_absent: null
      }
    },

    resetForm () {
      this.asserted_distribution = this.newAsserted()
      this.citation = {
        ...makeEmptyCitation(),
        source_id: this.lock.source ? this.citation.source_id : undefined,
        pages: this.lock.source ? this.citation.pages : undefined
      }
    }
  }
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