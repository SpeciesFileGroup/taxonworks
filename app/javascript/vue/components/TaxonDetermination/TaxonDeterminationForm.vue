<template>
  <div>
    <taxon-determination-otu v-model="otu"/>
    <taxon-determination-determiner v-model="taxonDetermination.roles_attributes"/>
    <div class="horizontal-left-content date-fields separate-bottom separate-top align-end">
      <date-fields
        v-model:year="taxonDetermination.year_made"
        v-model:month="taxonDetermination.month_made"
        v-model:day="taxonDetermination.day_made"
      />
      <date-now
        v-model:year="taxonDetermination.year_made"
        v-model:month="taxonDetermination.month_made"
        v-model:day="taxonDetermination.day_made"
      />
    </div>
    <button
      type="button"
      id="determination-add-button"
      :disabled="!taxonDetermination.otu_id"
      class="button normal-input button-submit separate-top"
      @click="addDetermination">
      Add
    </button>
  </div>
</template>

<script setup>
import { reactive, ref, watch } from 'vue'

import TaxonDeterminationOtu from './TaxonDeterminationOtu.vue'
import TaxonDeterminationDeterminer from './TaxonDeterminationDeterminer.vue'
import DateFields from 'components/ui/Date/DateFields.vue'
import DateNow from 'components/ui/Date/DateToday.vue'
import makeTaxonDetermination from 'factory/TaxonDetermination.js'

const emit = defineEmits(['onAdd'])

const taxonDetermination = reactive(makeTaxonDetermination())
const otu = ref()

watch(otu, () => {
  taxonDetermination.otu_id = otu.value?.id
})

const authorsString = author => author
  ? author?.person?.last_name || author?.last_name
  : ''

const dateString = ({ year_made, month_made, day_made }) => {
  const date = [
    year_made,
    month_made,
    day_made
  ].filter(value => value).join('-')

  return date
    ? `on ${date}`
    : ''
}

const addDetermination = () => {
  const { roles_attributes } = taxonDetermination

  emit('onAdd', {
    ...taxonDetermination,
    object_tag: `${otu.value.object_tag} by ${roles_attributes.map(author => authorsString(author)).join('; ')} ${dateString(taxonDetermination)}`
  })

  Object.assign(taxonDetermination, makeTaxonDetermination())
  otu.value = undefined
}

</script>
