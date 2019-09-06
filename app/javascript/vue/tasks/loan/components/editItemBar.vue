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
  import statusList from '../helpers/status.js'
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
      list() {
        return this.$store.getters[GetterNames.GetEditLoanItems]
      },
      loan() {
        return this.$store.getters[GetterNames.GetLoan]
      }
    },
    data: function () {
      return {
        date: undefined,
        status: undefined,
        statusList: statusList,
        displayBody: true
      }
    },
    methods: {
      updateDate() {
        var that = this
        this.list.forEach(function (item) {
          let loan_item = {
            id: item.id,
            date_returned: that.date
          }
          that.$store.dispatch(ActionNames.UpdateLoanItem, loan_item)
        })
      },
      updateStatus() {
        var that = this
        this.list.forEach(function (item) {
          let loan_item = {
            id: item.id,
            disposition: that.status
          }
          that.$store.dispatch(ActionNames.UpdateLoanItem, loan_item)
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
