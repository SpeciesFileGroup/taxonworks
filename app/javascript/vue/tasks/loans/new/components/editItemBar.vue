<template>
  <block-layout>
    <template #header>
      <h3>Update selected items</h3>
    </template>
    <template #options>
      <expand v-model="displayBody" />
    </template>
    <template
      #body
      v-if="displayBody"
    >
      <div id="loan-update-items">
        <div>
          <span><b>Loan item information</b></span>
          <hr />
          <div class="field label-above">
            <label>Status</label>
            <select
              v-model="status"
              class="normal-input information-input"
            >
              <option :value="null">None</option>
              <option
                v-for="item in statusList"
                :key="item"
                :value="item"
              >
                {{ item }}
              </option>
            </select>
            <button
              :disabled="!list.length || status === undefined"
              @click="updateStatus()"
              class="button button-submit normal-input margin-small-left"
            >
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
              pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}"
            />
            <button
              :disabled="date === undefined || !list.length"
              @click="updateDate()"
              class="button button-submit normal-input margin-small-left"
            >
              Update
            </button>
          </div>
        </div>
        <date-determination :list="list" />
      </div>
    </template>
  </block-layout>
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import ActionNames from '../store/actions/actionNames'
import statusList from '../const/status.js'
import expand from './expand.vue'
import dateDetermination from './dateDetermination.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()
const date = ref()
const status = ref()
const displayBody = ref(true)

const list = computed(() => {
  const loanItems = store.getters[GetterNames.GetLoanItems]
  const selectedLoanItems = store.getters[GetterNames.GetEditLoanItems]

  return loanItems.filter((item) => selectedLoanItems.includes(item.id))
})

function updateDate() {
  list.value.forEach((item) => {
    const loanItem = {
      id: item.id,
      date_returned: date.value
    }
    store.dispatch(ActionNames.UpdateLoanItem, loanItem)
  })
}

function updateStatus() {
  list.value.forEach((item) => {
    const loanItem = {
      id: item.id,
      disposition: status.value
    }

    store.dispatch(ActionNames.UpdateLoanItem, loanItem)
  })
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
