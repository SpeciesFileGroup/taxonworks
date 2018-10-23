<template>
  <div class="common_name_annotator data_attribute_annotator separate-bottom">
    <div class="separate-bottom">
      <div class="field separate-bottom">
        <input
          type="text"
          placeholder="Name"
          v-model="common_name.name">
      </div>
      <autocomplete
        class="separate-bottom"
        url="/geographic_areas/autocomplete"
        param="term"
        label="label_html"
        display="label"
        placeholder="Select a geopgrahic area"
        @getItem="common_name.geographic_area_id = $event.id"/>
      <autocomplete
        class="separate-bottom"
        url="/languages/autocomplete"
        param="term"
        label="label_html"
        display="label"
        placeholder="Select a language"
        @getItem="common_name.language_id = $event.id"/>
      <label>Start year</label>
      <input
        type="number"
        v-model="common_name.start_year"
        min="1600"
        max="3000">
      <label>End year</label>
      <input
        type="number"
        v-model="common_name.end_year"
        min="1600"
        max="3000">
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
      :header="['name', 'geographic area', 'language', '']"
      :attributes="['name', ['geographic_area', 'object_tag'], 'language_tag']"
      :list="list"
      @delete="removeItem"
      class="list"/>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete.vue'
import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import TableList from '../../../table_list'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    Autocomplete,
    TableList
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
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }
    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>

