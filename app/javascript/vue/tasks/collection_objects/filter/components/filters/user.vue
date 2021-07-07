<template>
  <div>
    <h3 class="flex-separate">
      Housekeeping
      <span
        class="margin-small-left"
        v-if="!user.user_target || (!user.user_date_start && !user.user_date_end)"
        data-icon="warning"
        title="Select a date range first to pick a date"/>
    </h3>
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
    <h3>Target</h3>
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
    <h3>Date range</h3>
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
            :disabled="!user.user_date_start"
            class="date-input"
            v-model="user.user_date_end">
          <button
            type="button"
            class="button normal-input button-default margin-small-left"
            @click="setActualDateStart"
            @dblclick="setActualDateEnd">
            Now
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import { ProjectMember } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  computed: {
    user: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },
    startDate () {
      return this.user.user_date_start
    }
  },

  emits: [
    'update:modelValue',
    'onUserslist'
  ],

  data () {
    return {
      users: [],
      options: [
        {
          label: 'Both',
          value: undefined
        },
        {
          label: 'Created at',
          value: 'created'
        },
        {
          label: 'Updated at',
          value: 'updated'
        }
      ]
    }
  },
  watch: {
    startDate (newVal) {
      if (!newVal) {
        this.user.user_date_end = undefined
      }
    }
  },
  mounted () {
    ProjectMember.all().then(response => {
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
    setActualDateStart () {
      this.user.user_date_start = new Date().toISOString().split('T')[0]
    },
    setActualDateEnd () {
      this.user.user_date_end = new Date().toISOString().split('T')[0]
    }
  }
}
</script>
