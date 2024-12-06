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
        v-model="store.citation"
        v-model:lock="store.lock.source"
        :klass="BIOLOGICAL_ASSOCIATION"
        :target="BIOLOGICAL_ASSOCIATION"
        @lock="(e) => (store.lock.source = e)"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { useStore } from '../../store/store'
import { BIOLOGICAL_ASSOCIATION } from '@/constants'
import { RouteNames } from '@/routes/routes.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()

function openTask() {
  window.open(RouteNames.NewSource)
}
</script>
