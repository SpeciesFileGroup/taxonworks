<template>
  <div>
    <h2>Select user and range date</h2>
    <div class="field">
      <select v-model="user">
        <option
          v-for="u in users"
          :key="u.id"
          :value="u.id">
          {{ u.name }}
        </option>
      </select>
    </div>
    <h3>Date range</h3>
    <div class="field">
      <label>Start date:</label>
      <br>
      <input type="date">
    </div>
    <div class="field">
      <label>End date:</label>
      <br>
      <input type="date">
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      users: [],
      user: undefined
    }
  }
}
</script>
