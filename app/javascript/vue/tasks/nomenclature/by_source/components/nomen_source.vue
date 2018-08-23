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
        default: window.location.href
      },
      sourceText: {
        type: String,
        default: 'This is the source from which we derive all the taxa and otus'
      },
    }
  }
</script>