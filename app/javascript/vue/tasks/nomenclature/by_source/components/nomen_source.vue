<template>
  <div
      style="width:400px; height:200px;">
    <h2>Nomenclatural source: </h2>
    <pre>{{ sourceText }}</pre>
    <autocomplete
      url="/sources/autocomplete"
      min="2"
      param="term"
      label="label"
      placeholder="search for a Source"
      @getItem="getNewSource($event)"
    />
  </div>
</template>
<script>
  import Autocomplete from "../../../../components/autocomplete";
  export default {
    components: {
      Autocomplete
    },
    data() {
      return {
        sourceText: 'Invalid source or no source supplied'
        ,
        sourceID: undefined,
        source: {}
      }
    },
  methods: {
    getSource() {
      if (this.sourceID) {
        this.$http.get('/sources/' + this.sourceID + '.json').then(response => {
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