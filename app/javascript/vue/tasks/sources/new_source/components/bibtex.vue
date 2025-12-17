<template>
  <VModal
    class="full_width"
    @close="emit('close', true)"
  >
    <template #header>
      <h3>New source from BibTeX</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isCreating"
        :full-screen="true"
        legend="Creating..."
      />
      <p>
        Creates a single record. For multiple records use a Source batch loader.
      </p>
      <textarea
        ref="textarea"
        class="full_width"
        v-model="bibtexInput"
        placeholder="@article{naumann1988ambositrinae,
  title={Ambositrinae (Insecta: Hymenoptera: Diapriidae)},
  author={Naumann, Ian D},
  journal={Fauna of New Zealand},
  volume={15},
  year={1988}
}"
      />
    </template>
    <template #footer>
      <VBtn
        color="create"
        medium
        :disabled="!bibtexInput.length"
        @click="createSource"
      >
        Create
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref, nextTick, onMounted, useTemplateRef } from 'vue'
import { useSourceStore } from '../store'
import { Source, Serial } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner'
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['close'])

const store = useSourceStore()
const bibtexInput = ref('')
const isCreating = ref(false)
const textareaRef = useTemplateRef('textarea')

onMounted(() => {
  nextTick(() => {
    textareaRef.value.focus()
  })
})

function createSource() {
  isCreating.value = true
  store.reset()
  Source.create({ bibtex_input: bibtexInput.value })
    .then(({ body }) => {
      bibtexInput.value = ''
      store.reset()
      store.setSource(body)

      if (body.journal) {
        Serial.where({ name: body.journal }).then(({ body }) => {
          const [serial] = body

          if (serial) {
            store.source.serial_id = serial.id
            store.source.isUnsaved = true
          }
        })
      }

      emit('close', true)
      TW.workbench.alert.create('New source from BibTeX created.', 'notice')
    })
    .catch(() => {})
    .finally(() => {
      isCreating.value = false
    })
}
</script>

<style scoped>
:deep(.modal-container) {
  width: 500px;
}
textarea {
  height: 200px;
}
</style>
