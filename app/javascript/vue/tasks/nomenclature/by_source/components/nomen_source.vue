<template>
  <div
      style="width:400px; height:200px;">
    <h2>Nomenclatural source: </h2>
    <pre>{{ sourceText }}</pre>
  </div>
</template>
<script>
  export default {
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
    getSource() {
      let pieces = window.location.href.split('/')
      this.sourceID = pieces[pieces.length - 1];
      if (this.sourceID) {
        this.$http.get('/sources/' + this.sourceID + '.json').then(response => {
          this.sourceText = response.body.id + ': "' + response.body.cached + '"';
          this.$emit('sourceID', this.sourceID);
        })
      }
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
    this.getSource()
    }
  }
</script>