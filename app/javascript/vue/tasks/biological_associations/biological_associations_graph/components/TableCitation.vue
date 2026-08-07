<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th class="full_width">{{ title }}</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="citation in citations"
        :key="citation.uuid"
      >
        <td>
          {{ citation.label }}
        </td>
        <td>
          <VBtn
            circle
            :color="!!citation.id ? 'destroy' : 'primary'"
            @click="
              () => {
                removeCitation(citation)
              }
            "
          >
            <VIcon
              x-small
              name="trash"
            />
          </VBtn>
        </td>
      </tr>
    </tbody>
  </table>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ref } from 'vue'

defineProps({
  citations: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['remove'])

const confirmationModalRef = ref()

async function removeCitation(citation) {
  const ok =
    !citation.id ||
    (await confirmationModalRef.value.show({
      title: 'Destroy citation',
      message: 'Are you sure you want to proceed?',
      okButton: 'Destroy',
      cancelButton: 'Cancel',
      typeButton: 'delete'
    }))

  if (ok) {
    emit('remove', citation)
  }
}
</script>
