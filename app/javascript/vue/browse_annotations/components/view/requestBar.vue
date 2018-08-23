<template>
  <div v-if="url">
    <hr>
    <div class="flex-separate">
      <span>
        JSON Request: 
        <a
          :href="url"
          target="_blank">{{ decodeURIComponent(url) }}</a>
      </span>
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