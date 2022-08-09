<template>
  <div class="common_name_annotator separate-bottom">
    <div class="separate-bottom">
      <label>Name</label>
      <input
        type="text"
        placeholder="Name"
        v-model="common_name.name">
    </div>

    <fieldset>
      <legend>Geographic area</legend>
      <smart-selector
        model="geographic_areas"
        klass="CollectingEvent"
        target="CollectingEvent"
        pin-section="GeographicAreas"
        pin-type="GeographicArea"
        @selected="selectedGeographic = $event"
      />
      <div>
        <smart-selector-item
          :item="selectedGeographic"
          label="name"
          @unset="selectedGeographic = null"
        />
      </div>
    </fieldset>

    <fieldset>
      <legend>Language</legend>
      <smart-selector
        model="languages"
        klass="AlternateValue"
        pin-section="Languages"
        pin-type="Language"
        @selected="selectedLanguage = $event"
      />
      <smart-selector-item
        :item="selectedLanguage"
        label="english_name"
        @unset="selectedLanguage = null"
      />
    </fieldset>

    <div class="field margin-medium-top">
      <label>Start year</label>
      <input
        class="date-input"
        type="number"
        placeholder="Start year"
        v-model="common_name.start_year"
        min="1600"
        max="3000"
      >
    </div>

    <div class="field">
      <label>End year</label>
      <input
        class="date-input"
        type="number"
        placeholder="End year"
        v-model="common_name.end_year"
        min="1600"
        max="3000"
      >
    </div>

    <div class="margin-medium-bottom">
      <v-btn
        color="create"
        medium
        :disabled="!validate"
        @click="createNew"
      >
        {{ common_name.id ? 'Update' : 'Create' }}
      </v-btn>
      <v-btn
        class="margin-small-left"
        medium
        color="primary"
        @click="reset"
        type="button"
      >
        New
      </v-btn>
    </div>

    <table-list
      label="object_tag"
      :header="['Name', 'Geographic area', 'Language', 'Start', 'End','']"
      :attributes="['name', ['geographic_area', 'object_tag'], 'language_tag', 'start_year', 'end_year']"
      :list="list"
      edit
      @edit="setCommonName"
      @delete="removeItem"
      class="list"
    />
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import TableList from 'components/table_list.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import makeCommonName from 'factory/CommonName.js'
import { addToArray } from 'helpers/arrays.js'
import { CommonName } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    TableList,
    SmartSelector,
    SmartSelectorItem,
    VBtn
  },

  computed: {
    validate () {
      return (this.common_name.name.length > 2 && this.common_name.otu_id)
    }
  },

  data () {
    return {
      common_name: makeCommonName(this.metadata.object_id),
      selectedGeographic: null,
      selectedLanguage: null
    }
  },

  mounted () {
    this.urlList = `/common_names.json?otu_id=${this.metadata.object_it}`
  },

  methods: {
    reset () {
      this.common_name = makeCommonName(this.metadata.object_id)
      this.selectedGeographic = null
      this.selectedLanguage = null
    },

    createNew () {
      const dataRequest = {
        ...this.common_name,
        geographic_area_id: this.selectedGeographic?.id || null,
        language_id: this.selectedLanguage?.id || null
      }

      const saveRequest = this.common_name.id
        ? CommonName.update(this.common_name.id, { common_name: dataRequest })
        : CommonName.create({ common_name: dataRequest })

      saveRequest.then(response => {
        addToArray(this.list, response.body)
        this.reset()
      })
    },

    setCommonName (common) {
      this.common_name.id = common.id
      this.common_name.name = common.name
      this.common_name.start_year = common.start_year
      this.common_name.end_year = common.end_year

      this.selectedGeographic = common.geographic_area_id
        ? {
            id: common.geographic_area_id,
            name: common.geographic_area?.object_tag
          }
        : null

      this.selectedLanguage = common.language_id
        ? {
            id: common.language_id,
            english_name: common.language_tag
          }
        : null
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
    .date-input {
      min-width: 150px;
    }
    .vue-autocomplete-input {
      width: 374px;
    }
  }
}
</style>

