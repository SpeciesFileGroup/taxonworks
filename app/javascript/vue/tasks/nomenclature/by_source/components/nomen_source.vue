<template>
  <div
    style="width:400px; height:200px;">
    <h2>Nomenclatural source: </h2>
    <pre>{{ value }}</pre>
  </div>
</template>
<script>
  export default {
    props: {
      value: {
        type: String,
        default: window.location.href.split('by_source/')[1]
      },
      sourceText: {
        type: String,
        default: 'This is the source from which we derive all the taxa and otus'
      },
    },
    methods: {
      items() {
        alert(window.location.search);
        return window.location.href.split('by_source/')[-1];
      }
    },
    computed: {
      itemS() {
        alert(window.location.search);
        return window.location.href.split('by_source/')[-1];
      }
    }
  }
</script>