<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <div class="field label-above">
    <label>Title</label>
    <textarea
      class="full_width"
      v-model="store.root.text"
      rows="2"
    />
  </div>

  <div class="field label-above">
    <label>Description (made public)</label>
    <textarea
      class="full_width"
      v-model="store.root.description"
      rows="2"
    />
  </div>

  <OtuChooser :lead="store.root" />

  <div class="field">
    <label>
      <input
        v-model="store.root.is_public"
        type="checkbox"
      />
      Is publicly accessible?
    </label>
  </div>

  <div class="field label-above">
    <label>Link out (for title/top of key; don't include http://)</label>
    <textarea
      class="full_width"
      v-model="store.root.link_out"
      rows="2"
    />
    <a :href="'http://' + store.root.link_out" target="_blank">
      {{ store.root.link_out }}
    </a>
  </div>

  <Annotations v-if="store.root.id"
    :object_type="LEAD"
    :object_id="store.root.id"
    v-model:depiction="depictions"
    v-model:citation="citations"
  />

  <div class="process">
    <VBtn
      class="process"
      color="create"
      medium
      :disabled="!store.root.text"
      @click="processKeyMeta()"
    >
      {{ updateButtonText }}
    </VBtn>
  </div>
</template>

<script setup>
import Annotations from './Annotations.vue'
import OtuChooser from './OtuChooser.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/spinner'
import { computed, ref } from 'vue'
import { LEAD } from '@/constants/index.js'
import { useStore } from '../store/useStore.js'
import { Lead } from '@/routes/endpoints'

const store = useStore()

const loading = ref(false)

const depictions = defineModel(
  'depiction',
  {
    type: Array,
    required: true
  }
)

const citations = defineModel(
  'citation',
  {
    type: Array,
    required: true
  }
)

const updateButtonText = computed(() => {
  if (store.root.id) {
    if (!store.root.text) {
      return 'Enter a title to enable udpate'
    }
    return 'Update key metadata'
  } else {
    if (!store.root.text) {
      return "Enter a title to enable save"
    }
    return 'Create new key'
  }
})

function processKeyMeta() {
  const payload = {
    lead: store.root
  }

  loading.value = true
  if (!store.root.id) {
    Lead.create(payload)
      .then(({ body }) => {
        store.$reset()
        store.loadKey(body)
        TW.workbench.alert.create('New key created.', 'notice')
      })
      .catch(() => {})
  } else {
    Lead.update_meta(store.root.id, payload)
      .then(() => {
        TW.workbench.alert.create('Key metadata updated.', 'notice')
      })
      .catch(() => {})
  }
  loading.value = false
}
</script>

<style lang="scss" scoped>
.process {
  text-align: center;
}
</style>