<template>
  <BlockLayout :warning="!store.citation.source_id">
    <template #header>
      <div class="flex-separate full_width middle">
        <h3>Source</h3>
        <VBtn
          color="primary"
          @click="openTask"
        >
          New
        </VBtn>
      </div>
    </template>
    <template #body>
      <FormCitation
        :fieldset="false"
        lock-button
        use-session
        v-model="store.citation"
        v-model:lock="store.lock.citation"
        :klass="BIOLOGICAL_ASSOCIATION"
        :target="BIOLOGICAL_ASSOCIATION"
        @update="sendBroadcast"
        @lock="(e) => (store.lock.citation = e)"
      >
        <template #tabs-right>
          <VBroadcast v-model="isBroadcastActive" />
        </template>
      </FormCitation>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref } from 'vue'
import { useStore } from '../../store/store'
import { BIOLOGICAL_ASSOCIATION } from '@/constants'
import { RouteNames } from '@/routes/routes.js'
import { useBroadcastChannel } from '@/composables'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import VBroadcast from '@/components/ui/VBroadcast/VBroadcast.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()

const isBroadcastActive = ref(false)

const { post } = useBroadcastChannel({
  name: 'citation',
  onMessage({ data }) {
    if (isBroadcastActive.value) {
      Object.assign(store.citation, data)
    }
  }
})

function sendBroadcast(data) {
  if (isBroadcastActive.value) {
    const { id, uuid, global_id, ...rest } = data

    post(rest)
  }
}

function openTask() {
  window.open(RouteNames.NewSource)
}
</script>
