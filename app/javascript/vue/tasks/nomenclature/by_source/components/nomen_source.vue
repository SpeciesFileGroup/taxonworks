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
            this.$emit('source_id', this.sourceID);
          })
        }
      }
    }
  ,
  mounted: function () {
    this.getSource()
    }
  }
</script>