<template>
  <div>
    <h2>Select date</h2>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="partial">
        Partial overlap search
      </label>
    </div>
    <div class="field">
      <label>Start date</label>
      <br>
      <input 
        type="date"
        v-model="search_start_date">
    </div>

    <div class="field">
      <label>End date</label>
      <br>
      <input 
        type="date"
        v-model="search_end_date">
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      search_start_date: undefined,
      search_end_date: undefined,
      partial: false
    }
  }
}
</script>
