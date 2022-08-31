<template>
  <fieldset>
    <legend>Source</legend>
    <smart-selector
      ref="sourceSmartSelector"
      model="sources"
      klass="TypeMaterial"
      pin-section="Sources"
      pin-type="Source"
      label="cached"
      @selected="setSource"
    />
    <template v-if="typeMaterial.originCitation">
      <hr>
      <div class="horizontal-left-content margin-medium-top">
        <span v-html="typeMaterial.originCitation.cached" />
        <span
          class="button circle-button btn-undo button-default"
          @click="removeCitation"
        />
      </div>
      <input
        class="margin-small-top"
        type="text"
        v-model="typeMaterial.originCitation.pages"
        placeholder="Pages"
      >
    </template>
  </fieldset>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import SmartSelector from 'components/ui/SmartSelector.vue'

const store = useStore()
const typeMaterial = computed({
  get: () => store.getters[GetterNames.GetTypeMaterial],
  set: value => store.commit(MutationNames.SetTypeMaterial, value)
})

const removeCitation = () => {
  typeMaterial.value.originCitation = null
}

const setSource = source => {
  typeMaterial.value.originCitation = {
    source_id: source.id,
    cached: source.cached,
    pages: undefined
  }
}
</script>
