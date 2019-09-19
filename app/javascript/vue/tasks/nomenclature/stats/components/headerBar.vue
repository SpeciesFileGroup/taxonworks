<template>
  <div class="panel content separate-bottom">
    <div class="flex-separate middle">
      <span>
        JSON Request: {{ jsonUrl }}
      </span>
    </div>
  </div>
</template>

<script>

export default {
  props: {
    jsonUrl: {
      type: String,
      default: ''
    }
  }
}

</script>
