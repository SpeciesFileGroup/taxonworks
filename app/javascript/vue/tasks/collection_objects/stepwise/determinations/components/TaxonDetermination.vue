<template>
  <div class="panel content">
    <h3>Determination</h3>
    <TaxonDeterminationForm
      ref="determinationForm"
      class="margin-medium-bottom"
      @on-add="setTaxonDetermination"
    />
    <TaxonDeterminationList
      v-model="determinationList"
      @edit="loadDetermination"
      @delete="setTaxonDetermination()"
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from 'components/TaxonDetermination/TaxonDeterminationList.vue'
import useStore from '../composables/useStore'

const {
  setTaxonDetermination,
  taxonDetermination
} = useStore()

const determinationList = computed(() =>
  taxonDetermination.value
    ? [taxonDetermination.value]
    : []
)

const determinationForm = ref(null)

const loadDetermination = (determination) => {
  determinationForm.value.setDetermination(determination)
}
</script>
