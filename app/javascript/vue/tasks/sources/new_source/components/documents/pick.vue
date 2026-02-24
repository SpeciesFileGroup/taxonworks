<template>
  <div>
    <VAutocomplete
      class="source-autocomplete field"
      url="/documents/autocomplete"
      label="label"
      min="2"
      placeholder="Select a document"
      clear-after
      :excludedIds="documents"
      param="term"
      @get-item="createNew"
    />
    <ConfirmationModal ref="confirmationModal" />
  </div>
</template>

<script setup>
import { useSourceStore } from '../../store'
import { useTemplateRef, computed } from 'vue'
import { Document } from '@/routes/endpoints'
import VAutocomplete from '@/components/ui/Autocomplete'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const props = defineProps({
  source: {
    type: Object,
    required: true
  },

  isPublic: {
    type: Boolean,
    required: true
  }
})

const store = useSourceStore()
const confirmationModalRef = useTemplateRef('confirmationModal')

const documents = computed(() => store.documentation.map((d) => d.document_id))

async function createNew({ id }) {
  const { body: document } = await Document.find(id)

  if (props.isPublic && !document.is_public) {
    const ok = await showConfirmationModal()

    if (ok) {
      await Document.update(id, {
        document: { is_public: true }
      })
    }
  }

  store.saveDocumentation({
    document_id: id,
    annotated_global_entity: decodeURIComponent(props.source.global_id)
  })
}

function showConfirmationModal() {
  return confirmationModalRef.value.show({
    title: 'Create documentation',
    message:
      "You're trying to create documentation using a previously uploaded document that isn't public. Do you want to make it public?",
    typeButton: 'submit',
    cancelButton: 'Keep private',
    okButton: 'Make it public'
  })
}
</script>

<style scoped>
:deep(.source-autocomplete) {
  .vue-autocomplete-input {
    width: 100%;
  }
}
</style>
