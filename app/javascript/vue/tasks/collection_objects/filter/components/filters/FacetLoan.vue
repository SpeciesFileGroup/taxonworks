<template>
  <FacetContainer>
    <h3>Loans</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            v-model="params.on_loan"
            type="checkbox"
          >
          Currently on loan
        </label>
      </li>
      <li>
        <label>
          <input
            v-model="params.loaned"
            type="checkbox"
          >
          Loaned
        </label>
      </li>
      <li>
        <label>
          <input
            v-model="params.never_loaned"
            type="checkbox"
          >
          Never loaned
        </label>
      </li>
    </ul>
    <autocomplete
      class="margin-medium-top"
      url="/loans/autocomplete"
      param="term"
      clear-after
      placeholder="Search a loan..."
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
import { URLParamsToJSON } from 'helpers/url/parse.js'
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
  set: value => emit('update:modelValue', value)
})

watch(
  loanList,
  newVal => {
    this.loans.loan_id = newVal.map(item => item.id)
  }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)
  const loanIds = urlParams.loan_id || []

  params.value.on_loan = urlParams.on_loan
  params.value.loaned = urlParams.loaned
  params.value.never_loaned = urlParams.never_loaned

  loanIds.forEach(id => addLoan(id))
})

const addLoan = id => {
  Loan.find(id).then(({ body }) => {
    loanList.value.push(body)
  })
}

const removeLoan = index => {
  loanList.value.splice(index, 1)
}
</script>
