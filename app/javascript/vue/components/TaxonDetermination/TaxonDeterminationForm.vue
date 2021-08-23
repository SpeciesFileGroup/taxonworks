<template>
  <div>
    <h3>Determinations</h3>
    <div id="taxon-determination-digitize">
      <fieldset
        class="separate-bottom">
        <legend>OTU</legend>
        <div class="horizontal-left-content separate-bottom align-start">
          <smart-selector
            class="margin-medium-bottom full_width"
            model="otus"
            ref="smartSelector"
            pin-section="Otus"
            pin-type="Otu"
            :autocomplete="false"
            :otu-picker="true"
            target="TaxonDetermination"
            @selected="setOtu"
          />
        </div>
        <div
          v-if="taxonDetermination.otu"
          class="horizontal-left-content">
          <p v-html="taxonDetermination.otu"/>
          <span
            class="circle-button button-default btn-undo"
            @click="taxonDetermination.otu_id = undefined; taxonDetermination.otu = undefined"/>
        </div>
      </fieldset>

      <div class="horizontal-left-content date-fields separate-bottom separate-top align-end">
        <date-fields
          v-model:year="taxonDetermination.year_made"
          v-model:month="taxonDetermination.month_made"
          v-model:day="taxonDetermination.day_made"
        />
        <button
          type="button"
          class="button normal-input button-default separate-left separate-right"
          @click="setActualDate">
          Now
        </button>
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
  </div>
</template>

<script setup>
import { computed } from 'vue'

import DateFields from 'components/ui/Date/DateFields.vue'
import makeTaxonDetermination from 'factory/TaxonDetermination.js'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => makeTaxonDetermination()
  }
})

const emit = defineEmits([
  'update:modelValue',
  'onAdd'
])

const taxonDetermination = computed(() => ({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
}))

const addDetermination = () => {
  emit('onAdd', taxonDetermination)
  taxonDetermination.value = makeTaxonDetermination()
}

const setActualDate = () => {
  const today = new Date()
  taxonDetermination.value.day_made = today.getDate()
  taxonDetermination.value.month_made = today.getMonth() + 1
  taxonDetermination.value.year_made = today.getFullYear()
}

</script>
