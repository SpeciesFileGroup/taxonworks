<template>
  <div>
    <h2 class="flex-separate">
      Housekeeping
      <span
        class="margin-small-left"
        v-if="!user.user_target || (!user.user_date_start && !user.user_date_end)"
        data-icon="warning"
        title="Select a date range first to pick a date"/>
    </h2>
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
      <ul class="no_bullets">
        <li
          v-for="item in options"
          :key="item.value">
          <label>
            <input
              :value="item.value"
              v-model="user.user_target"
              type="radio">
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start date:</label>
        <br>
        <input 
          type="date"
          class="date-input"
          v-model="user.user_date_start">
      </div>
      <div class="field">
        <label>End date:</label>
        <br>
        <div class="horizontal-left-content">
          <input
            type="date"
            class="date-input"
            v-model="user.user_date_end">
          <button
            type="button"
            class="button normal-input button-default margin-small-left"
            @click="setActualDate">
            Now
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import { GetUsers } from '../../request/resources'
import { URLParamsToJSON } from 'helpers/url/parse.js'

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
  mounted () {
    GetUsers().then(response => {
      this.users = response.body
      this.$emit('onUserslist', this.users)
      this.users.unshift({ user: { name: '--none--', id: undefined } })
    })

    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      this.user.user_id = urlParams.user_id
      this.user.user_date_start = urlParams.user_date_start
      this.user.user_date_end = urlParams.user_date_end
      this.user.user_target = urlParams.user_target
    }
  },
  methods: {
    setActualDate () {
      this.user.user_date_end = new Date().toISOString().split('T')[0]
    }
  }
}
</script>
