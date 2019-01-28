<template>
  <div id="vue-task-asserted-distribution-new">
    <h1>Task - New asserted distribution</h1>
    <div class="horizontal-left-content align-start">
      <div class="separate-right">
        <div class="horizontal-left-content middle">
          <source-component
            v-model="asserted_distribution.citations_attributes[0]"
            ref="sourceComponent"
            :class="{
              highlight: highlight.source
            }"
            class="separate-right"/>
          <lock-component v-model="locks.citations_attributes"/>
        </div>
        <div class="horizontal-left-content middle separate-bottom">
          <otu-component
            class="separate-right"
            :class="{
              highlight: highlight.otu
            }"
            ref="otuComponent"
            v-model="asserted_distribution.otu_id"/>
          <lock-component v-model="locks.otu_id"/>
        </div>
        <div class="horizontal-left-content middle">
          <geographic-area
            class="separate-right"
            ref="geoComponent"
            :class="{
              highlight: highlight.geo
            }"
            v-model="asserted_distribution.geographic_area_id"/>
          <lock-component v-model="locks.geographic_area_id"/>
        </div>
      </div>
      <div class="separate-left">
        <div class="horizontal-left-content middle">
          <custom-attributes
            class="separate-right"
            :object-id="asserted_distribution.id"
            object-type="AssertedDistribution"
            model="AssertedDistribution"
            @onUpdate="asserted_distribution.data_attributes_attributes = $event"/>
          <lock-component v-model="locks.data_attributes_attributes"/>
        </div>
        <div class="horizontal-left-content middle">
          <button
            type="button"
            :disabled="!validate"
            class="button normal-input button-submit"
            @click="saveAssertedDistribution">Save
          </button>
          <button
            type="button"
            :disabled="!validate"
            class="button normal-input button-submit"
            @click="createAndNewAssertedDistribution">Save and new
          </button>
        </div>
      </div>
    </div>
    <table-component
      :list="list"
      @onSourceOtu="setSourceOtu"
      @onSourceGeo="setSourceGeo"
      @onOtuGeo="setGeoOtu"
      @highlight="highlight = $event"
      @remove="removeAssertedDistribution"/>
  </div>
</template>

<script>

import SourceComponent from './components/source'
import OtuComponent from './components/otu'
import GeographicArea from './components/geographicArea'
import CustomAttributes from 'components/custom_attributes/predicates/predicates'
import TableComponent from './components/table'
import LockComponent from 'components/lock'

import { CreateAssertedDistribution, RemoveAssertedDistribution, UpdateAssertedDistribution } from './request/resources.js'

export default {
  components: {
    SourceComponent,
    OtuComponent,
    GeographicArea,
    CustomAttributes,
    TableComponent,
    LockComponent
  },
  computed: {
    validate() {
      return this.asserted_distribution.otu_id &&
        this.asserted_distribution.geographic_area_id &&
        this.asserted_distribution.citations_attributes[0].source_id
    }
  },
  data() {
    return {
      asserted_distribution: this.newAssertedDistribution(),
      list: [],
      highlight: {
        otu: false,
        source: false,
        geo: false
      },
      locks: {
        otu_id: false,
        geographic_area_id: false,
        citation_attributes: false,
        data_attributes_attributes: false
      }
    }
  },
  methods: {
    newAssertedDistribution() {
      return {
        id: undefined,
        otu_id: undefined, 
        geographic_area_id: undefined,
        is_absent: undefined,
        origin_citation_attributes: undefined,
        citations_attributes: [{
          id: undefined,
          source_id: undefined,
          is_original: undefined,
          pages: undefined,
        }],
        data_attributes_attributes: []
      }
    },
    newWithLock() {
      let newObject = this.newAssertedDistribution()
      let keys = Object.keys(newObject)
      keys.forEach(key => {
        newObject[key] = this.locks[key] ? this.asserted_distribution[key] : (Array.isArray(newObject[key]) ? [] : undefined)
      })
      if(!this.locks.citations_attributes) {
        newObject.citations_attributes.push({
          id: undefined,
          source_id: undefined,
          is_original: undefined,
          pages: undefined,
        })
      }
      this.asserted_distribution = newObject
    },
    createAndNewAssertedDistribution() {
      this.saveAssertedDistribution().then(response => {
        this.newWithLock()
      })
    },
    saveAssertedDistribution() {
      return new Promise((resolve, reject) => { 
        if(this.asserted_distribution.id) {
          UpdateAssertedDistribution(this.asserted_distribution).then(response => {
            this.$set(this.list, this.list.findIndex(item => {
              return item.id == response.body.id
            }), response.body)
            this.asserted_distribution.id = response.body.id
            this.asserted_distribution.citations_attributes = response.body.citations
            this.asserted_distribution.data_attributes_attributes = response.body.data_attributes
            TW.workbench.alert.create('Asserted distribution was successfully updated.', 'notice')
            resolve(response.body)
          })
        }
        else {
          CreateAssertedDistribution(this.asserted_distribution).then(response => {
            this.asserted_distribution.id = response.body.id
            this.asserted_distribution.citations_attributes = response.body.citations
            this.asserted_distribution.data_attributes_attributes = response.body.data_attributes
            this.list.push(response.body)
            TW.workbench.alert.create('Asserted distribution was successfully created.', 'notice')
            resolve(response.body)
          })
        }
      })
    },
    removeAssertedDistribution(asserted) {
      RemoveAssertedDistribution(asserted.id).then(response => {
        this.list.splice(this.list.findIndex(item => {
          return item.id == asserted.id
        }), 1)
      })
    },
    setSourceOtu(item) {
      this.asserted_distribution.id = undefined
      this.setCitation(item)
      this.asserted_distribution.otu_id = item.otu.id
      this.$refs.sourceComponent.setSelected(item.citation)
      this.$refs.otuComponent.setSelected(item.otu)
    },
    setSourceGeo(item) {
      this.setCitation(item)
      this.asserted_distribution.geographic_area_id = item.geo.id
      this.$refs.sourceComponent.setSelected(item.citation.source)
      this.$refs.geoComponent.setSelected(item.geo)
    },
    setGeoOtu(item) {
      this.asserted_distribution.id = item.id
      this.asserted_distribution.geographic_area_id = item.geo.id
      this.asserted_distribution.otu_id = item.otu.id
      this.$refs.geoComponent.setSelected(item.geo)  
      this.$refs.otuComponent.setSelected(item.otu)    
    },
    setCitation(item) {
      this.asserted_distribution.citations_attributes = []
      this.asserted_distribution.citations_attributes.push({
        source_id: item.citation.source_id,
        is_original: item.citation.is_original,
        pages: item.citation.pages
      })      
    }
  }
}
</script>
<style lang="scss">
  #vue-task-asserted-distribution-new {
    .highlight {
      fieldset {
        background-color: #E3E8E3 !important;
      }
    }
  }
</style>
