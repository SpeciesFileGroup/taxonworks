<template>
  <div>
    <h3>Repository</h3>
    <fieldset class="fieldset">
      <legend>Repository</legend>
      <div class="horizontal-left-content align-start separate-bottom">
        <SmartSelector
          class="full_width"
          ref="smartSelector"
          model="repositories"
          target="CollectionObject"
          klass="CollectionObject"
          pin-section="Repositories"
          pin-type="Repository"
          @selected="setRepository"
        />
      </div>
      <template v-if="repository">
        <div class="middle separate-top">
          <span data-icon="ok" />
          <span class="separate-right"> {{ repository.name }}</span>
          <span
            class="circle-button button-default btn-undo"
            @click="unsetRepository"
          />
        </div>
      </template>
    </fieldset>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector'

const repositoryId = defineModel({
  type: [String, Number],
  default: undefined
})

const repository = ref()

function setRepository(data) {
  repository.value = data
  repositoryId.value = data.id
}

function unsetRepository() {
  repository.value = undefined
  repositoryId.value = undefined
}
</script>
