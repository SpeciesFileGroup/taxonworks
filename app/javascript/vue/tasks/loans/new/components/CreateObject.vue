<template>
  <div>
    <p>Select loan item type</p>
    <div class="field">
      <label
        v-for="(_, key) in AUTOCOMPLETE_URL"
        :key="key"
        class="label-flex"
      >
        <input
          type="radio"
          v-model="type"
          :value="key"
        />
        {{ key }}
      </label>
    </div>
    <div class="field">
      <VAutocomplete
        v-if="!selectedObject"
        min="2"
        placeholder="Select loan item"
        label="label_html"
        display="label"
        clear-after
        :url="AUTOCOMPLETE_URL[type]"
        param="term"
        @get-item="setObject"
      />
      <div
        v-else
        class="horizontal-left-content"
      >
        <SmartSelectorItem
          :item="selectedObject"
          label="label_html"
          @unset="selectedObject = null"
        />
      </div>
    </div>
    <div v-if="isOtu">
      <div class="field">
        <label class="d-block">Total</label>
        <input
          v-model="total"
          class="normal-input"
          type="text"
        />
      </div>
      <button
        class="normal-input button button-submit"
        type="button"
        :disabled="!selectedObject"
        @click="createItem()"
      >
        Create
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useStore } from 'vuex'
import { LoanItem } from '@/routes/endpoints'
import { MutationNames } from '../store/mutations/mutations'
import { OTU, COLLECTION_OBJECT, CONTAINER } from '@/constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import extend from '../const/extend.js'

const props = defineProps({
  loan: {
    type: Object,
    required: true
  }
})

const store = useStore()
const selectedObject = ref()
const type = ref(COLLECTION_OBJECT)

const isOtu = computed(() => type.value === OTU)
const total = ref(1)

const AUTOCOMPLETE_URL = {
  [OTU]: '/otus/autocomplete',
  [CONTAINER]: '/containers/autocomplete',
  [COLLECTION_OBJECT]: '/collection_objects/autocomplete'
}

watch(selectedObject, (newVal) => {
  if (newVal && !isOtu.value) {
    createItem()
  }
})

watch(type, () => {
  selectedObject.value = null
})

function setObject(item) {
  selectedObject.value = item
}

function createItem() {
  const payload = {
    loan_id: props.loan.id,
    loan_item_object_id: selectedObject.value.id,
    loan_item_object_type: type.value
  }

  if (isOtu.value) {
    Object.assign(payload, { total: total.value })
  }

  LoanItem.create({ loan_item: payload, extend })
    .then((response) => {
      store.commit(MutationNames.AddLoanItem, response.body)
      TW.workbench.alert.create('Loan item was successfully created.', 'notice')
    })
    .catch(() => {})
    .finally(() => {
      setObject(undefined)
    })
}
</script>
