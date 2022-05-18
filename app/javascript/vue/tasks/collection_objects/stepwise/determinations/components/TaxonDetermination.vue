<template>
  <div class="panel content">
    <h3>Determination</h3>
    <TaxonDeterminationForm
      @onAdd="setTaxonDetermination"
    />
  </div>
</template>

<script setup>
import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import useStore from '../composables/useStore'

const { setTaxonDetermination } = useStore()
</script>