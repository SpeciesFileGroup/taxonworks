<template>
  <FacetContainer>
    <h3 class="flex-separate">Loan status</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            v-model="params.on_loan"
            type="checkbox"
          />
          Currently on loan
        </label>
      </li>
      <li>
        <label>
          <input
            v-model="params.loaned"
            type="checkbox"
          />
          Loaned at least once
        </label>
      </li>
      <li>
        <label>
          <input
            v-model="params.never_loaned"
            type="checkbox"
          />
          Never loaned
        </label>
      </li>
    </ul>
    <h3 class="flex-separate">In loan</h3>
    <autocomplete
      class="margin-medium-top"
      url="/loans/autocomplete"
      param="term"
      clear-after
      placeholder="Search loans..."
      label="label_html"
      @get-item="addLoan($event.id)"
    />
    <display-list
      :list="loanList"
      label="object_tag"
      :delete-warning="false"
      @delete-index="removeLoan"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { Loan } from 'routes/endpoints'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import DisplayList from 'components/displayList.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const loanList = ref([])
const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

watch(
  loanList,
  (newVal) => {
    params.value.loan_id = newVal.map((item) => item.id)
  },
  { deep: true }
)

watch(
  () => props.modelValue.loan_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      loanList.value = []
    }
  }
)

onBeforeMount(() => {
  const loanIds = params.value.loan_id || []

  loanIds.forEach((id) => addLoan(id))
})

const addLoan = (id) => {
  Loan.find(id).then(({ body }) => {
    loanList.value.push(body)
  })
}

const removeLoan = (index) => {
  loanList.value.splice(index, 1)
}
</script>
