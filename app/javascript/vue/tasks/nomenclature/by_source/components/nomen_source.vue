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
    </span>
    <ul
      v-if="source && source.authors.length"
      class="no_bullets">
      <li 
        v-for="author in source.authors"
        :key="author.id">
        <a
          :href="`${author.object_url}`"
          target="blank">{{ author.object_tag }}</a>
      </li>
    </ul>
  </div>
</template>
<script>

  import Autocomplete from "components/autocomplete";
  import RadialAnnotator from "components/annotator/annotator.vue";
  import PinComponent from "components/pin.vue"
  import RadialObject from "components/radial_object/radialObject.vue"
  import DefaultSource from 'components/getDefaultPin'

  export default {
    components: {
      Autocomplete,
      RadialAnnotator,
      RadialObject,
      PinComponent,
      DefaultSource
    },
    data() {
      return {
        source: undefined,
        sourceID: undefined,
      }
    },
  methods: {
    getSource() {
      if (this.sourceID) {
        this.$http.get('/sources/' + this.sourceID + '.json').then(response => {
          this.source = response.body
          history.pushState(null, null, `/tasks/nomenclature/by_source?source_id=${this.source.id}`)
          this.$emit('sourceID', this.sourceID);
        })
      }
    },
    getNewSource(id) {
      this.sourceID = id.toString()
      this.getSource()
      this.$emit('sourceID', this.sourceID);  // since we avoided the AJAX
    },
    getSelectOptions(onModel) {
      this.$http.get(this.selectOptionsUrl, {params: {klass: this.onModel}}).then(response => {
        this.tabs = Object.keys(response.body);
        this.list = response.body;
        this.$http.get(this.allSelectOptionUrl).then(response => {
          if(response.body.length) {
            this.moreOptions = ['all']
          }
          this.$set(this.list, 'all', response.body);
        })
      })
    }
  },
  mounted() {
    let urlParams = new URLSearchParams(window.location.search)
    let sourceId = urlParams.get('source_id')

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