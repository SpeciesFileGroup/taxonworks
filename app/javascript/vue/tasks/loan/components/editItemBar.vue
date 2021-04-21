<template>
  <div class="panel loan-box">
    <spinner
      :show-spinner="false"
      :resize="false"
      :show-legend="false"
      v-if="!loan.id"/>
    <div class="header flex-separate middle">
      <h3 class="">Update selected items</h3>
      <expand v-model="displayBody"/>
    </div>
    <div
      class="body horizontal-left-content align-start"
      v-if="displayBody">
      <div class="edit-loan-container column-left">
        <span><b>Loan item information</b></span>
        <hr>
        <div class="separate-top">
          <div class="field">
            <label>Status</label>
            <select
              v-model="status"
              class="normal-input information-input">
              <option
                v-for="item in statusList"
                :value="item">{{ item }}
              </option>
            </select>
            <button
              :disabled="!status || !list.length"
              @click="updateStatus()"
              class="button button-submit normal-input">Update
            </button>
          </div>
          <div class="field">
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
              class="button button-submit normal-input">Update
            </button>
          </div>
        </div>
      </div>
      <date-determination :list="list"/>
    </div>
  </div>
</template>

<script>

import ActionNames from '../store/actions/actionNames'
import { GetterNames } from '../store/getters/getters'
import statusList from '../const/status.js'
import expand from './expand.vue'
import dateDetermination from './dateDetermination.vue'
import spinner from 'components/spinner.vue'

export default {
  components: {
    expand,
    spinner,
    dateDetermination
  },

  computed: {
    list () {
      return this.$store.getters[GetterNames.GetEditLoanItems]
    },

    loan () {
      return this.$store.getters[GetterNames.GetLoan]
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
  .column-left {
    width: 40%;
  }

  .information-input {
    width: 130px;
  }
</style>
