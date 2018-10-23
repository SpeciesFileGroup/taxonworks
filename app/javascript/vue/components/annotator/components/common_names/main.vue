<template>
  <div class="common_name_annotator separate-bottom">
    <div class="separate-bottom">
      <div class="separate-bottom">
        <input
          type="text"
          placeholder="Name"
          v-model="common_name.name">
      </div>
      <div class="horizontal-left-content separate-bottom">
        <autocomplete
          url="/geographic_areas/autocomplete"
          param="term"
          label="label_html"
          display="label"
          ref="geoAutocomplete"
          placeholder="Select a geopgrahic area"
          @getItem="common_name.geographic_area_id = $event.id"/>
        <default-pinned
          section="GeographicAreas"
          type="GeographicArea"
          @getLabel="$refs.geoAutocomplete.setLabel($event)"
          @getId="common_name.geographic_area_id = $event"/>
      </div>
      <autocomplete
        class="separate-bottom"
        url="/languages/autocomplete"
        param="term"
        label="label_html"
        display="label"
        ref="langAutocomplete"
        placeholder="Select a language"
        @getItem="common_name.language_id = $event.id"/>
      <div class="separate-bottom">
        <input
          class="date-input"
          type="number"
          placeholder="Start year"
          v-model="common_name.start_year"
          min="1600"
          max="3000">
      </div>
      <div>
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
        Create
      </button>
    </div>
    <table-list
      label="object_tag"
      :header="['Name', 'Geographic area', 'Language', 'Start', 'End','']"
      :attributes="['name', ['geographic_area', 'object_tag'], 'language_tag', 'start_year', 'end_year']"
      :list="list"
      @delete="removeItem"
      class="list"/>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete.vue'
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
    }
  },
  data() {
    return {
      common_name: this.newCommonName()
    }
  },
  mounted() {
    this.urlList = `/common_names.json?otu_id=${this.metadata.object_it}`
  },
  methods: {
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
      this.create('/common_names', {common_name: this.common_name}).then(response => {
        this.list.push(response.body)
        this.common_name = this.newCommonName()
        this.$refs.geoAutocomplete.setLabel('')
        this.$refs.langAutocomplete.setLabel('')
      })
    }
  }
}
</script>

<style lang="scss">
.radial-annotator {
  .common_name_annotator {
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

