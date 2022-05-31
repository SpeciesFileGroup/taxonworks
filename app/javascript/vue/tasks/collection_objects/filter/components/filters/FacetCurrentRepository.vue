<template>
  <div>
    <h3>Current repository</h3>
    <SmartSelector
      v-model="repositorySelected"
      model="repositories"
      klass="CollectionObject"
      pin-section="Repositories"
      pin-type="Repository"
      @selected="setRepository"/>
    <div
      v-if="repositorySelected"
      class="middle flex-separate separate-top">
      <span v-html="repositorySelected.name"/>
      <span
        class="button button-circle btn-undo button-default"
        @click="unsetRepository"/>
    </div>
  </div>
</template>

<script setup>

import SmartSelector from 'components/ui/SmartSelector'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Repository } from 'routes/endpoints'
import { computed, ref, watch } from 'vue'

const props = defineProps({
    modelValue: {
      type: [Number, String],
      default: undefined
    }
  })

const emit = defineEmits(['update:modelValue'])

const currentRepositoryId = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

watch(currentRepositoryId, 
  id => {
    if (!id) {
      unsetRepository()
    }
  },
  { deep: true }
)

const repositorySelected = ref(undefined)

const setRepository = (repository) => {
  repositorySelected.value = repository
  currentRepositoryId.value = repository.id
}

const unsetRepository = () => {
  repositorySelected.value = undefined
  currentRepositoryId.value = undefined
}

const urlParams = URLParamsToJSON(location.href)

if (urlParams.current_repository_id) {
  Repository.find(urlParams.current_repository_id).then(response => {
    setRepository(response.body)
  })
}

</script>

<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
