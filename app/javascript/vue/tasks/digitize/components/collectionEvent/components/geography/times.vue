<template>
  <div>
    <div>
      <label>Start time</label>
      <div class="horizontal-left-content">
        <div class="separate-right">
          <label>Hour</label>
          <input type="text">
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input type="text">
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input type="text">
        </div>
      </div>
    </div>
    <div>
      <label>End time</label>
      <div class="horizontal-left-content">
        <div class="separate-right">
          <label>Hour</label>
          <input type="text">
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input type="text">
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input type="text">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {

}
</script>

<style scoped>
  input {
    max-width: 60px;
  }
</style>
