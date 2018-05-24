<template>
  <div v-if="url">
    <hr>
    <div class="flex-separate">
      <span>JSON Request: {{ decodeURIComponent(url) }} </span>
      <span>({{ total }} records.)</span>
    </div>
    <hr>
  </div>
</template>

<script>
  export default {
    props: {
      url: {
        type: String,
        default: ''
      },
      total: {
        type: Number,
        default: 0
      }
    }
  }
</script>