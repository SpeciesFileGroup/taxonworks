<template>
  <div class="panel panel__content">
    <h2 class="panel_title">Biocurations</h2>
    <ul>
    </ul>
  </div>
</template>

<script setup>
import { BiocurationClassification } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import { useStore } from 'vuex'
import { computed, watch } from 'vue'

const store = useStore()
const collectionObject = computed(() => store.getters[GetterNames.GetCollectionObject])
watch(collectionObject)

BiocurationClassification.where({ biological_collection_object_id: newVal }).then(response => {
  this.createdBiocutarions = response.body
})
</script>
