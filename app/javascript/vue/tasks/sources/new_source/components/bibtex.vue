<template>
  <modal-component
    @close="$emit('close', true)"
    class="full_width"
  >
    <template #header>
      <h3>New source from BibTeX</h3>
    </template>
    <template #body>
      <spinner-component
        v-if="creating"
        :full-screen="true"
        legend="Creating..."
      />
      <p>
        Creates a single record. For multiple records use a Source batch loader.
      </p>
      <textarea
        ref="textareaRef"
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
  </modal-component>
</template>

<script setup>
import SpinnerComponent from '@/components/ui/VSpinner'
import ModalComponent from '@/components/ui/Modal'
import newSource from '../const/source'
import setParam from '@/helpers/setParam'
import VBtn from '@/components/ui/VBtn/index.vue'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { Source, Serial } from '@/routes/endpoints'
import { ref, nextTick, onMounted } from 'vue'
import { useStore } from 'vuex'

const emit = defineEmits(['close'])

const bibtexInput = ref('')
const creating = ref(false)
const textareaRef = ref(null)
const store = useStore()

onMounted(() => {
  nextTick(() => {
    textareaRef.value.focus()
  })
})

function createSource() {
  creating.value = true
  store.dispatch(ActionNames.ResetSource)
  Source.create({ bibtex_input: bibtexInput.value })
    .then((response) => {
      bibtexInput.value = ''
      store.dispatch(ActionNames.ResetSource)
      emit('close', true)
      store.commit(
        MutationNames.SetSource,
        Object.assign(newSource(), response.body)
      )

      if (response.body.journal) {
        Serial.where({ name: response.body.journal }).then(({ body }) => {
          if (body.length) {
            store.commit(MutationNames.SetSerialId, body[0].id)
          }
        })
      }

      setParam('/tasks/sources/new_source', 'source_id', response.body.id)
      TW.workbench.alert.create('New source from BibTeX created.', 'notice')
    })
    .catch(() => {})
    .finally(() => {
      creating.value = false
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
