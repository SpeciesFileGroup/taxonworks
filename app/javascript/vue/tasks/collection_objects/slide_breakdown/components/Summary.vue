<template>
  <div class="panel content">
    <h2>Summary</h2>
    <div class="horizontal-left-content">
      <button
        @click="$emit('update')"
        type="button"
        class="button normal-input button-submit margin-medium-right full_width">
        Update
      </button>
      <button
        type="button"
        class="button normal-input button-submit full_width">
        Update and next
      </button>
    </div>
  </div>
</template>

<script>
export default {

}
</script>

<style>

</style>