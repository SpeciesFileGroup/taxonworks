<template>
  <div id="vue-task-asserted-distribution-new">
    <spinner-component
      v-if="loading"
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      legend="Loading..."/>
    <h1>Task - New asserted distribution</h1>
    <div class="horizontal-left-content align-start">
      <div class="panel-section">
        <div class="horizontal-left-content middle panel-section separate-right">
          <source-component
            v-model="asserted_distribution.citations_attributes[0]"
            ref="sourceComponent"
            :class="{
              highlight: highlight.source
            }"
            class="separate-right"/>
          <lock-component v-model="locks.citations_attributes"/>
        </div>
        <p class="horizontal-left-content">
          <span class="separate-right">Add source: </span>
          <ul class="no_bullets context-menu">
            <li class="navigation-item context-menu-option">
              <a
                target="blank" 
                href="/sources/new">New</a>
            </li>
            <li class="navigation-item context-menu-option">
              <a
                target="blank"
                href="/tasks/bibliography/verbatim_reference/new">New from citation</a>
            </li>
            <li class="navigation-item context-menu-option">
              <a
                target="blank" 
                href="/tasks/sources/individual_bibtex_source/index">New from bibtex</a>
            </li>
          </ul>
        </p>
      </div>
      <div class="horizontal-left-content middle separate-bottom panel-section separate-left separate-right">
        <otu-component
          class="separate-right"
          :class="{
            highlight: highlight.otu
          }"
          ref="otuComponent"
          v-model="asserted_distribution.otu_id"/>
        <lock-component v-model="locks.otu_id"/>
      </div>
      <div class="horizontal-left-content middle panel-section separate-left">
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
    <div class="horizontal-center-content middle">
      <button
        type="button"
        v-shortkey="[getMacKey(), 's']"
        @shortkey="saveAssertedDistribution()"
        :disabled="!validate"
        class="button normal-input button-submit separate-right"
        @click="saveAssertedDistribution">Save
      </button>
      <button
        type="button"
        v-shortkey="[getMacKey(), 'n']"
        @shortkey="createAndNewAssertedDistribution()"
        :disabled="!validate"
        class="button normal-input button-submit separate-left separate-right"
        @click="createAndNewAssertedDistribution">Save and new
      </button>
      <span
        class="cursor-pointer"
        @click="newWithLock">
        <span data-icon="reset"/>Reset
      </span>
    </div>
    <table-component
      class="full_width"
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
import TableComponent from './components/table'
import LockComponent from 'components/lock'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey'

import { CreateAssertedDistribution, RemoveAssertedDistribution, UpdateAssertedDistribution, LoadRecentRecords } from './request/resources.js'

export default {
  components: {
    SourceComponent,
    OtuComponent,
    GeographicArea,
    TableComponent,
    LockComponent,
    SpinnerComponent
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
      loading: true,
      highlight: {
        otu: false,
        source: false,
        geo: false
      },
      locks: {
        otu_id: false,
        geographic_area_id: false,
        citation_attributes: false,
      }
    }
  },
  mounted() {
    this.addShortcutsDescription()
    LoadRecentRecords().then(response => {
      this.list = response.body
      this.loading = false
    })
  },
  methods: {
    addShortcutsDescription() {
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+s`, 'Save asserted distribution changes', 'New asserted distribution')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+n`, 'Save and create new asserted distribution', 'New asserted distribution')
    },
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
        }]
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
    getMacKey() {
      return GetMacKey()
    },
    createAndNewAssertedDistribution() {
      if(!this.validate) return
      this.saveAssertedDistribution().then(response => {
        this.newWithLock()
      })
    },
    saveAssertedDistribution() {
      if(!this.validate) return
      return new Promise((resolve, reject) => { 
        if(this.asserted_distribution.id) {
          UpdateAssertedDistribution(this.asserted_distribution).then(response => {
            this.$set(this.list, this.list.findIndex(item => {
              return item.id == response.body.id
            }), response.body)
            this.asserted_distribution.id = response.body.id
            this.setCitation(response.body.citations[0])
            TW.workbench.alert.create('Asserted distribution was successfully updated.', 'notice')
            resolve(response.body)
          })
        }
        else {
          this.asserted_distribution.citations_attributes[0].id = undefined
          CreateAssertedDistribution(this.asserted_distribution).then(response => {
            this.asserted_distribution.id = response.body.id
            this.setCitation(response.body.citations[0])
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
      this.newWithLock()
      this.asserted_distribution.id = undefined
      this.setCitation(item.citation)
      this.asserted_distribution.otu_id = item.otu.id
      this.$refs.sourceComponent.setSelected(item.citation)
      this.$refs.otuComponent.setSelected(item.otu)
    },
    setSourceGeo(item) {
      this.newWithLock()
      this.setCitation(item.citation)
      this.asserted_distribution.geographic_area_id = item.geo.id
      this.$refs.sourceComponent.setSelected(item.citation.source)
      this.$refs.geoComponent.setSelected(item.geo)
    },
    setGeoOtu(item) {
      this.newWithLock()
      this.asserted_distribution.id = item.id
      this.asserted_distribution.geographic_area_id = item.geo.id
      this.asserted_distribution.otu_id = item.otu.id
      this.$refs.geoComponent.setSelected(item.geo)  
      this.$refs.otuComponent.setSelected(item.otu)    
    },
    setCitation(item) {
      this.asserted_distribution.citations_attributes = []
      this.asserted_distribution.citations_attributes.push({
        id: item.id,
        source_id: item.source_id,
        is_original: item.is_original,
        pages: item.pages
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
    .panel-section {
      flex-grow: 1;
      flex-basis: 0;
    }
    fieldset {
      width: 100%;
    }
  }
</style>
