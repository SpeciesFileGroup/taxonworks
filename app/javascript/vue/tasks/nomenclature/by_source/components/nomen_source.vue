<template>
  <div class="nomen-source">
    <autocomplete
      url="/sources/autocomplete"
      min="2"
      param="term"
      label="label"
      :clear-after="true"
      placeholder="search for a Source"
      @getItem="getNewSource($event)"
    />
    <span
      v-if="source"
      class="source-text horizontal-left-content">
      <span
        class="separate-right"
        v-html="source.cached"/>
      <a
        class="separate-right separate-left"
        :href="`/sources/${sourceID}`"
        target="blank">Show
      </a>
      <radial-annotator :global-id="source.global_id"/>
    </span>
  </div>
</template>
<script>

  import Autocomplete from "../../../../components/autocomplete";
  import RadialAnnotator from "../../../../components/annotator/annotator.vue";

  export default {
    components: {
      Autocomplete,
      RadialAnnotator
    },
    data() {
      return {
        sourceText: 'Invalid source or no source supplied',
        source: undefined,
        sourceID: undefined,
      }
    },
  methods: {
    getSource() {
      if (this.sourceID) {
        this.$http.get('/sources/' + this.sourceID + '.json').then(response => {
          this.source = response.body
          this.sourceText = response.body.id + ': "' + response.body.cached + '"';
          this.$emit('sourceID', this.sourceID);
        })
      }
    },
    getNewSource(event) {
      this.source = event;
      this.sourceID = this.source.id.toString();  // propped everywhere as string
      this.sourceText = this.source.label;
      // this.getSource();  // why do an ajax when we already got the information?
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
    let pieces = window.location.href.split('/');
    this.sourceID = pieces[pieces.length - 1];
    if (this.sourceID.length && Number.isInteger(Number(this.sourceID))) this.getSource();
  }
}
</script>
<style lang="scss">
  #nomenclature-by-source-task {
    .nomen-source {
      height:100px;
      .source-text {
        font-size: 110%;
      }
      .vue-autocomplete-input {
        width: 400px !important;
      }
    }
  }
</style>