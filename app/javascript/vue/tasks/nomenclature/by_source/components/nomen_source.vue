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
      @getItem="sourceID = $event.id; getSource()"
    />
  </div>
</template>
<script>
  import Autocomplete from "../../../../components/autocomplete";
  export default {
    components: {Autocomplete},
    props: {
      value: {
        type: String,
        default: window.location.href.split('by_source/')[1]
      },
    },
    data: function() {
      return {
        sourceText: 'Invalid source or no source supplied'
        ,
        sourceID: undefined
      }
    },
  methods: {
    getRequestSource() {
      let pieces = window.location.href.split('/');
      this.sourceID = pieces[pieces.length - 1];
      getSource();
    },
    getSource() {
      if (this.sourceID) {
        this.$http.get('/sources/' + this.sourceID + '.json').then(response => {
          this.sourceText = response.body.id + ': "' + response.body.cached + '"';
          this.$emit('sourceID', this.sourceID);
        })
      }
    },
    getNewSource(event) {
      this.sourceID = event.id;
      getSource();
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
  }
  ,
  mounted: function () {
    let pieces = window.location.href.split('/');
    this.sourceID = pieces[pieces.length - 1];
    this.getSource();
    }
  }
</script>