<template>
  <div>
    <h2>User</h2>
    <div class="field">
      <select v-model="user">
        <option
          v-for="u in users"
          :key="u.id"
          :value="u.user.id">
          {{ u.user.name }}
        </option>
      </select>
    </div>
    <h3>Date range</h3>
    <div class="horizontal-left-content">
      <div class="field separate-right">
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
  </div>
</template>

<script>

import { GetUsers } from '../../request/resources'

export default {
  data () {
    return {
      users: [],
      user: undefined
    }
  },
  mounted () {
    GetUsers().then(response => {
      this.users = response.body
    })
  }
}
</script>
