<template>
  <div id="vue-task-asserted-distribution-new">
    <spinner-component
      v-if="loading"
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      legend="Loading..."/>
    <h1>Task - New asserted distribution</h1>
    <nav-bar-component class="margin-medium-bottom">
      <div class="flex-separate middle">
        <div>
          <span
            v-if="currentAssertedDistribution"
            v-html="currentAssertedDistribution.object_tag"/>
          <span v-else>New record</span>
        </div>
        <div class="horizontal-center-content middle">
          <label class="middle margin-small-right">
            <input
              v-model="autosave"
              type="checkbox">
            Autosave
          </label>
          <button
            type="button"
            v-hotkey="shortcuts"
            :disabled="!validate"
            class="button normal-input button-submit separate-left separate-right"
            @click="saveAssertedDistribution">{{ asserted_distribution.id ? 'Update' : 'Create' }}
          </button>
          <button
            type="button"
            class="button normal-input button-default padding-medium-left padding-medium-right"
            @click="newWithLock">
            New
          </button>
        </div>
      </div>
    </nav-bar-component>
    <div class="horizontal-left-content align-start">
      <div class="width-30">
        <div class="horizontal-left-content panel-section separate-right align-start">
          <source-component
            v-model="asserted_distribution"
            ref="sourceComponent"
            class="separate-right full_width"/>
          <lock-component
            class="margin-medium-top"
            v-model="locks.citation"/>
        </div>
        <p class="horizontal-left-content">
          <ul class="no_bullets context-menu">
            <li class="navigation-item context-menu-option">
              <a
                href="/tasks/sources/new_source">New source</a>
            </li>
          </ul>
        </p>
      </div>
      <div class="horizontal-left-content separate-bottom separate-left separate-right align-start width-40">
        <otu-component
          class="separate-right full_width"
          ref="otuComponent"
          v-model="asserted_distribution.otu"/>
        <lock-component
          class="margin-medium-top"
          v-model="locks.otu"/>
      </div>
      <div class="horizontal-left-content separate-left align-start width-30">
        <geographic-area
          class="separate-right full_width"
          ref="geoComponent"
          @selected="triggerAutosave"
          v-model="asserted_distribution"/>
        <lock-component
          class="margin-medium-top"
          v-model="locks.geographicArea"/>
      </div>
    </div>

    <table-component
      class="full_width"
      :list="list"
      @onSourceOtu="setSourceOtu"
      @onSourceGeo="setSourceGeo"
      @onOtuGeo="setGeoOtu"
      @remove="removeAssertedDistribution"/>
  </div>
</template>

<script>

import SourceComponent from './components/source'
import OtuComponent from './components/otu'
import GeographicArea from './components/geographicArea'
import TableComponent from './components/table'
import LockComponent from 'components/ui/VLock/index.vue'
import SpinnerComponent from 'components/spinner'
import NavBarComponent from 'components/layout/NavBar'
import platformKey from 'helpers/getPlatformKey'

import { Source, AssertedDistribution } from 'routes/endpoints'

export default {
  components: {
    SourceComponent,
    OtuComponent,
    GeographicArea,
    TableComponent,
    LockComponent,
    SpinnerComponent,
    NavBarComponent
  },

  computed: {
    validate () {
      return this.asserted_distribution.otu && this.asserted_distribution.geographicArea && this.asserted_distribution.citation.source
    },
    currentAssertedDistribution () {
      return this.list.find(item => item.id === this.asserted_distribution.id)
    },
    shortcuts () {
      const keys = {}

      keys[`${platformKey}+s`] = this.saveAssertedDistribution

      return keys
    }
  },

  data () {
    return {
      asserted_distribution: this.newAssertedDistribution(),
      list: [],
      loading: true,
      autosave: true,
      locks: {
        otu: false,
        geographicArea: false,
        citation: false
      }
    }
  },

  created () {
    AssertedDistribution.where({ recent: true, per: 15, extend: ['source'] }).then(response => {
      this.list = response.body
      this.loading = false
    })
    TW.workbench.keyboard.createLegend(`${platformKey()}+s`, 'Save and create new asserted distribution', 'New asserted distribution')
  },

  methods: {
    triggerAutosave () {
      if (this.validate && this.autosave) {
        this.saveAssertedDistribution()
      }
    },

    newAssertedDistribution () {
      return {
        id: undefined,
        otu: undefined,
        geographicArea: undefined,
        is_absent: undefined,
        citation: {
          id: undefined,
          source: undefined,
          pages: undefined,
          is_original: undefined
        }
      }
    },

    newWithLock () {
      const newObject = this.newAssertedDistribution()
      const keys = Object.keys(newObject)
      keys.forEach(key => {
        if (this.locks[key]) {
          newObject[key] = this.asserted_distribution[key]
        }
      })
      this.asserted_distribution = newObject
    },

    saveAssertedDistribution () {
      if (!this.validate) return
      const assertedDistribution = {
        id: this.asserted_distribution.id,
        otu_id: this.asserted_distribution.otu.id,
        geographic_area_id: this.asserted_distribution.geographicArea.id,
        is_absent: this.asserted_distribution.is_absent,
        citations_attributes: [{
          id: this.asserted_distribution.citation.id,
          source_id: this.asserted_distribution.citation.source.id,
          is_original: this.asserted_distribution.citation.is_original,
          pages: this.asserted_distribution.citation.pages
        }]
      }
      if (assertedDistribution.id) {
        this.updateRecord(assertedDistribution)
      } else {
        assertedDistribution.citations_attributes[0].id = undefined
        AssertedDistribution.where({
          otu_id: assertedDistribution.otu_id,
          geographic_area_id: assertedDistribution.geographic_area_id,
          extend: ['source']
        }).then(response => {
          if (response.body.length) {
            assertedDistribution.id = response.body[0].id
            this.updateRecord(assertedDistribution)
          } else {
            this.createRecord(assertedDistribution)
          }
        })
      }
    },

    createRecord (asserted_distribution) {
      AssertedDistribution.create({ asserted_distribution, extend: ['source'] }).then(response => {
        this.list.unshift(response.body)
        TW.workbench.alert.create('Asserted distribution was successfully created.', 'notice')
        this.refreshSmarts()
        this.newWithLock()
      })
    },

    updateRecord (asserted_distribution) {
      AssertedDistribution.update(asserted_distribution.id, { asserted_distribution, extend: ['source'] }).then(response => {
        const index = this.list.findIndex(item => item.id === response.body.id)

        this.list[index] = response.body
        TW.workbench.alert.create('Asserted distribution was successfully updated.', 'notice')
        this.refreshSmarts()
        this.newWithLock()
      })
    },

    removeAssertedDistribution (asserted) {
      AssertedDistribution.destroy(asserted.id).then(() => {
        this.list.splice(this.list.findIndex(item => item.id === asserted.id), 1)
      })
    },
    refreshSmarts () {
      this.$refs.sourceComponent.refresh()
      this.$refs.geoComponent.refresh()
      this.$refs.otuComponent.refresh()
    },
    setSourceOtu (item) {
      this.newWithLock()
      this.setCitation(item.citations[0])
      this.asserted_distribution.id = undefined
      this.asserted_distribution.otu = item.otu
    },
    setSourceGeo (item) {
      this.newWithLock()
      this.setCitation(item.citations[0])
      this.asserted_distribution.geographicArea = item.geographic_area
      this.asserted_distribution.is_absent = item.is_absent
    },
    setGeoOtu (item) {
      this.newWithLock()
      this.autosave = false
      this.asserted_distribution.id = item.id
      this.asserted_distribution.geographicArea = item.geographic_area
      this.asserted_distribution.otu = item.otu
      this.asserted_distribution.is_absent = item.is_absent
    },
    setCitation (citation) {
      Source.find(citation.source_id).then(response => {
        this.asserted_distribution.citation = {
          id: undefined,
          source: response.body,
          is_original: citation.is_original,
          pages: citation.pages
        }
      })
    }
  }
}
</script>
