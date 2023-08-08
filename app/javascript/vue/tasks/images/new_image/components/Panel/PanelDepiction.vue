<template>
  <BlockLayout>
    <template #header>
      <h3>Depiction</h3>
    </template>
    <template #body>
      <label>Caption</label>
      <br />
      <textarea
        v-model="depiction"
        rows="5"
        class="full_width"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()

const depiction = computed({
  get: () => store.getters[GetterNames.GetDepiction].caption,

  set(value) {
    store.commit(MutationNames.SetDepictionCaption, value)
  }
})
</script>
