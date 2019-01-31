<template>
  <div class="panel content">
    <h2>Use the options below to build attributions and depictions, then apply it to your images.</h2>
    <div class="flexbox">
      <div class="separate-right">
        <div class="horizontal-left-content separate-bottom">
          <input
            class="input-apply"
            disabled="true"
            type="text">
          <button
            type="button"
            class="button normal-input button-submit separate-left">
            Apply
          </button>
        </div>
        <div class="horizontal-left-content">
          <input
            class="input-apply"
            disabled="true"
            type="text">
          <button
            type="button"
            class="button normal-input button-submit separate-left">
            Apply
          </button>
        </div>
      </div>
      <button 
        class="button normal-input button-submit item"
        type="button">
        Apply both
      </button>
    </div>
  </div>
</template>

<script>
export default {

}
</script>

<style scoped>
  .input-apply {
    width: 100%;
  }
</style>
