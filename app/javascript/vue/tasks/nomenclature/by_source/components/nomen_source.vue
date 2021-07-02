<template>
  <div class="nomen-source">
    <div class="horizontal-left-content separate-bottom">
      <autocomplete
        url="/sources/autocomplete"
        min="2"
        param="term"
        label="label"
        :clear-after="true"
        placeholder="Search for a Source"
        @getItem="getNewSource($event.id)"
      />
      <default-source
        section="Sources"
        @getId="getNewSource"
        type="Source"/>
    </div>
    <span
      v-if="source"
      class="source-text horizontal-left-content">
      <span>
        <span v-html="source.cached"/>
        <span class="separate-right">(Published on {{ source.cached_nomenclature_date }})</span>
      </span>
      <radial-object :global-id="source.global_id"/>
      <radial-annotator :global-id="source.global_id"/>
      <pin-component
        v-if="source.id"
        :object-id="source.id"
        :type="source.base_class"/>
      <a
        v-for="document in source.documents"
        class="circle-button btn-download"
        :download="document.document_file_file_name"
        :title="document.document_file_file_name"
        :href="document.document_file"></a>
    </span>
    <ul
      v-if="source && source.author_roles.length"
      class="no_bullets">
      <li 
        v-for="author in source.author_roles"
        :key="author.id">
        <a
          :href="`${author.object_url}`"
          target="blank">{{ author.object_tag }}</a>
      </li>
    </ul>
  </div>
</template>
<script>

import Autocomplete from 'components/ui/Autocomplete';
import RadialAnnotator from 'components/radials/annotator/annotator.vue';
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import DefaultSource from 'components/getDefaultPin'
import AjaxCall from 'helpers/ajaxCall'
import { Source } from 'routes/endpoints'

export default {
  components: {
    Autocomplete,
    RadialAnnotator,
    RadialObject,
    PinComponent,
    DefaultSource
  },

  data () {
    return {
      source: undefined,
      sourceID: undefined,
    }
  },

  $emit: ['sourceID'],

  methods: {
    getSource () {
      if (this.sourceID) {
        Source.find(this.sourceID).then(response => {
          this.source = response.body
          history.pushState(null, null, `/tasks/nomenclature/by_source?source_id=${this.source.id}`)
          this.$emit('sourceID', this.sourceID);
        })
      }
    },

    getNewSource (id) {
      this.sourceID = id.toString()
      this.getSource()
      this.$emit('sourceID', this.sourceID);  // since we avoided the AJAX
    },

    getSelectOptions (onModel) {
      AjaxCall('get', this.selectOptionsUrl, { params: { klass: this.onModel } }).then(response => {
        this.tabs = Object.keys(response.body)
        this.list = response.body

        AjaxCall('get', this.allSelectOptionUrl).then(response => {
          if (response.body.length) {
            this.moreOptions = ['all']
          }
          this.list['all'] = response.body
        })
      })
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const sourceId = urlParams.get('source_id')

    if (/^\d+$/.test(sourceId)) {
      this.sourceID = sourceId
      this.getSource()
    }
  }
}
</script>
<style lang="scss">
  #nomenclature-by-source-task {
    .nomen-source {
      min-height:100px;
      .source-text {
        font-size: 110%;
      }
      .vue-autocomplete-input {
        width: 400px !important;
      }
    }
  }
</style>