<template>
  <BlockLayout :warning="required && !citation.source_id">
    <template #header>
      <div class="flex-separate full_width middle">
        <h3>Source</h3>
        <VBtn
          color="primary"
          @click="openNewSourceTask"
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
        v-model="citation"
        v-model:absent="isAbsent"
        v-model:lock="isLocked"
        :absent-field="absentField"
        :klass="target"
        :target="target"
        @update="sendBroadcast"
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
import { RouteNames } from '@/routes/routes.js'
import { useBroadcastChannel } from '@/composables'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VBroadcast from '@/components/ui/VBroadcast/VBroadcast.vue'

const isBroadcastActive = ref(false)

defineProps({
  // Model type of the object being cited, e.g. 'AssertedDistribution'
  target: {
    type: String,
    required: true
  },

  // Show the warning state until a source is selected
  required: {
    type: Boolean,
    default: false
  },

  absentField: {
    type: Boolean,
    default: false
  }
})

const citation = defineModel({
  type: Object,
  required: true
})

const isAbsent = defineModel('absent', {
  type: Boolean,
  default: false
})

const isLocked = defineModel('lock', {
  type: Boolean,
  default: false
})

const { post } = useBroadcastChannel({
  name: 'citation',
  onMessage({ data }) {
    if (isBroadcastActive.value) {
      Object.assign(citation.value, data)
    }
  }
})

function sendBroadcast(data) {
  if (isBroadcastActive.value) {
    const { id, uuid, global_id, ...rest } = data

    post(rest)
  }
}

function openNewSourceTask() {
  window.open(RouteNames.NewSource)
}
</script>
