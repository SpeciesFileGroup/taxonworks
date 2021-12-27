<template>
  <div class="common_name_annotator separate-bottom">
    <div class="separate-bottom separate-top">
      <div class="separate-bottom">
        <label>Name</label>
        <input
          type="text"
          placeholder="Name"
          v-model="common_name.name">
      </div>
      <label>Geographic area</label>
      <div class="horizontal-left-content separate-bottom">
        <template v-if="selectedGeographic">
          <span v-html="geographicLabel"/>
          <span
            class="circle-button button-default btn-undo"
            @click="common_name.geographic_area_id = null; selectedGeographic = undefined"/>
        </template>
        <template v-else>
          <autocomplete
            url="/geographic_areas/autocomplete"
            param="term"
            label="label_html"
            display="label"
            ref="geoAutocomplete"
            placeholder="Select a geopgrahic area"
            @getItem="selectedGeographic = $event; common_name.geographic_area_id = $event.id"/>
          <default-pinned
            section="GeographicAreas"
            type="GeographicArea"
            @getLabel="$refs.geoAutocomplete.setText($event)"
            @getId="common_name.geographic_area_id = $event"/>
        </template>
      </div>
      <label>Language</label>
      <div class="horizontal-left-content separate-bottom">
        <template v-if="selectedLenguage">
          <span v-html="languageLabel"/>
          <span
            class="circle-button button-default btn-undo"
            @click="common_name.language_id = null; selectedLenguage = undefined"/>
        </template>
        <template v-else>
          <autocomplete
            url="/languages/autocomplete"
            param="term"
            label="label_html"
            display="label"
            ref="langAutocomplete"
            placeholder="Select a language"
            @getItem="selectedLanguage = $event.label; common_name.language_id = $event.id"/>
        </template>
      </div>
      <div class="separate-bottom">
        <label>Start year</label>
        <input
          class="date-input"
          type="number"
          placeholder="Start year"
          v-model="common_name.start_year"
          min="1600"
          max="3000">
      </div>
      <div>
        <label>End year</label>
        <input
          class="date-input"
          type="number"
          placeholder="End year"
          v-model="common_name.end_year"
          min="1600"
          max="3000">
      </div>
    </div> 
    <div> 
      <button
        type="button"
        :disabled="!validate"
        @click="createNew"
        class="button normal-input button-submit">
        {{ common_name.id ? 'Update' : 'Create' }}
      </button>
      <button
        class="button normal-input button-default"
        @click="reset"
        type="button">
        Reset
      </button>
    </div>
    <table-list
      label="object_tag"
      :header="['Name', 'Geographic area', 'Language', 'Start', 'End','']"
      :attributes="['name', ['geographic_area', 'object_tag'], 'language_tag', 'start_year', 'end_year']"
      :list="list"
      :edit="true"
      @edit="editCommon"
      @delete="removeItem"
      class="list"/>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete.vue'
import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import TableList from 'components/table_list.vue'
import DefaultPinned from 'components/getDefaultPin.vue'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    Autocomplete,
    TableList,
    DefaultPinned
  },
  computed: {
    validate() {
      return (this.common_name.name.length > 2 && this.common_name.otu_id != undefined)
    },
    geographicLabel() {
      if(!this.selectedGeographic) return
      return this.selectedGeographic.hasOwnProperty('object_tag') ? this.selectedGeographic.object_tag : this.selectedGeographic.label
    },
    languageLabel() {
      if(!this.selectedLenguage) return
      return this.selectedLenguage
    }
  },
  data() {
    return {
      common_name: this.newCommonName(),
      selectedGeographic: undefined,
      selectedLenguage: undefined
    }
  },
  mounted() {
    this.urlList = `/common_names.json?otu_id=${this.metadata.object_it}`
  },
  methods: {
    reset() {
      this.common_name = this.newCommonName()
      this.selectedGeographic = undefined
      this.selectedLenguage = undefined
    },
    newCommonName() {
      return {
        id: undefined,
        name: '', 
        geographic_area_id: undefined, 
        otu_id: this.metadata.object_id, 
        language_id: undefined, 
        start_year: undefined, 
        end_year: undefined
      }
    },
    createNew() {
      if(this.common_name.id) {
        this.update(`/common_names/${this.common_name.id}.json`, { common_name: this.common_name }).then(response => {
          this.list[this.list.findIndex(item => { return item.id == this.common_name.id })] = response.body
          this.reset()
        })
      }
      else {
        this.create('/common_names', {common_name: this.common_name}).then(response => {
          this.list.push(response.body)
          this.reset()
        })
      }
    },
    editCommon(common) {
      this.common_name.id = common.id
      this.common_name.name = common.name
      if(common.hasOwnProperty('geographic_area')) {
        this.common_name.geographic_area_id = common.geographic_area_id
        this.selectedGeographic = common.geographic_area
      }
      if(common.language_tag) {
        this.common_name.language_id = common.language_id
        this.selectedLenguage = common.language_tag
      }
      this.common_name.start_year = common.start_year
      this.common_name.end_year = common.end_year
    }
  }
}
</script>

<style lang="scss">
.radial-annotator {
  .common_name_annotator {
    label {
      display: block;
    }
    button {
      min-width: 100px;
    }
    .date-input {
      min-width: 150px;
    }
    .vue-autocomplete-input {
      width: 374px;
    }
  }
}
</style>

