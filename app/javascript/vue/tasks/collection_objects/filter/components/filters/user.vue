<template>
  <div>
    <h2>User</h2>
    <div class="field">
      <select v-model="user.user_id">
        <option
          v-for="u in users"
          :key="u.id"
          :value="u.user.id">
          {{ u.user.name }}
        </option>
      </select>
    </div>
    <h3>Date range</h3>
    <div class="field">
      <select v-model="user.user_target">
        <option
          v-for="item in options"
          :value="item.value"
          :key="item.value">
          {{ item.label }}
        </option>
      </select>
    </div>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start date:</label>
        <br>
        <input 
          type="date"
          :disabled="!user.user_id || !user.user_target"
          v-model="user.user_date_start">
      </div>
      <div class="field">
        <label>End date:</label>
        <br>
        <input
          type="date"
          :disabled="!user.user_id || !user.user_target"
          v-model="user.user_date_end">
      </div>
    </div>
  </div>
</template>

<script>

import { GetUsers } from '../../request/resources'

export default {
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    user: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      users: [],
      options: [
        {
          label: '--None--',
          value: undefined
        },
        {
          label: 'created at',
          value: 'created'
        }, 
        { 
          label: 'updated',
          value: 'updated'
        }
      ]
    }
  },
  watch: {
    user: {
      handler (newVal) {
        if(!newVal.user_id || !newVal.user_target) {
          this.user.user_date_start = undefined
          this.user.user_date_end = undefined
        }
      },
      deep: true
    }
  },
  mounted () {
    GetUsers().then(response => {
      this.users = response.body
      this.$emit('onUserslist', this.users)
      this.users.unshift({ user: { name: '--none--', id: undefined } })
    })
  }
}
</script>
