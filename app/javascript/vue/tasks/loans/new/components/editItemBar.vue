<template>
  <block-layout>
    <template #header>
      <h3>Update selected items</h3>
    </template>
    <template #options>
      <expand v-model="displayBody"/>
    </template>
    <template
      #body
      v-if="displayBody">
      <div id="loan-update-items">
        <div>
          <span><b>Loan item information</b></span>
          <hr>
          <div class="field label-above">
            <label>Status</label>
            <select
              v-model="status"
              class="normal-input information-input">
              <option
                v-for="item in statusList"
                :key="item"
                :value="item">{{ item }}
              </option>
            </select>
            <button
              :disabled="!status || !list.length"
              @click="updateStatus()"
              class="button button-submit normal-input margin-small-left">
              Update
            </button>
          </div>
          <div class="field label-above">
            <label>Returned on date</label>
            <input
              v-model="date"
              type="date"
              class="information-input"
              required
              pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}">
            <button
              :disabled="!date || !list.length"
              @click="updateDate()"
              class="button button-submit normal-input margin-small-left">
              Update
            </button>
          </div>
        </div>
        <date-determination :list="list"/>
      </div>
    </template>
  </block-layout>
</template>

<script>

import ActionNames from '../store/actions/actionNames'
import { GetterNames } from '../store/getters/getters'
import statusList from '../const/status.js'
import expand from './expand.vue'
import dateDetermination from './dateDetermination.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'

export default {
  components: {
    expand,
    dateDetermination,
    BlockLayout
  },

  computed: {
    list () {
      return this.$store.getters[GetterNames.GetEditLoanItems]
    }
  },

  data () {
    return {
      date: undefined,
      status: undefined,
      statusList: statusList,
      displayBody: true
    }
  },
  methods: {
    updateDate () {
      this.list.forEach((item) => {
        const loanItem = {
          id: item.id,
          date_returned: this.date
        }
        this.$store.dispatch(ActionNames.UpdateLoanItem, loanItem)
      })
    },

    updateStatus () {
      this.list.forEach((item) => {
        const loanItem = {
          id: item.id,
          disposition: this.status
        }
        this.$store.dispatch(ActionNames.UpdateLoanItem, loanItem)
      })
    }
  }
}
</script>
<style scoped>
  #loan-update-items {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }

  .information-input {
    width: 200px;
  }
</style>
