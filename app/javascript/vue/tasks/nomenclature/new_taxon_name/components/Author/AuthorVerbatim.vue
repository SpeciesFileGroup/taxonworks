<template>
  <div>
    <div class="field label-above">
      <label>Verbatim author</label>
      <input
        ref="verbatimAuthorInput"
        type="text"
        class="w-96"
        v-model="verbatimAuthor"
      />
    </div>
    <div class="fields label-above">
      <label>Verbatim year</label>
      <input
        type="text"
        v-model="verbatimYear"
        v-number-only
      />
    </div>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed, ref } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { vNumberOnly } from '@/directives/index.js'

const verbatimAuthorInput = ref(null)

function focus() {
  verbatimAuthorInput.value?.focus()
}

defineExpose({ focus })

const store = useStore()

const verbatimAuthor = computed({
  get: () => store.getters[GetterNames.GetTaxonAuthor],
  set: (value) => {
    store.commit(MutationNames.SetTaxonAuthor, value)
    store.commit(MutationNames.UpdateLastChange)
  }
})

const verbatimYear = computed({
  get: () => store.getters[GetterNames.GetTaxonYearPublication],
  set: (value) => {
    store.commit(MutationNames.SetTaxonYearPublication, value)
    store.commit(MutationNames.UpdateLastChange)
  }
})
</script>
