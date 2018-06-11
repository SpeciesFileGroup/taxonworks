<template>
  <div>
    <div>
      <label>Start date</label>
      <div class="horizontal-left-content">
        <div class="separate-right">
          <label>Year</label>
          <input type="text">
        </div>
        <div class="separate-left separate-right">
          <label>Month</label>
          <input type="text">
        </div>
        <div class="separate-left">
          <label>Day</label>
          <input type="text">
        </div>
      </div>
    </div>
    <div>
      <label>End date</label>
      <div class="horizontal-left-content">
        <div class="separate-right">
          <label>Year</label>
          <input type="text">
        </div>
        <div class="separate-left separate-right">
          <label>Month</label>
          <input type="text">
        </div>
        <div class="separate-left">
          <label>Day</label>
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
