<template>
  <VModal
    :container-style="{ width: '600px' }"
    @close="() => emit('close')"
  >
    <template #header>
      <h3>Collecting event - {{ param.field }}</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isUpdating"
        full-screen
        legend="Updating..."
      />
      <div>
        <div class="field label-above">
          <textarea
            v-if="textarea"
            v-model="fieldValue"
            class="full_width"
            rows="5"
          />
          <input
            v-else
            type="text"
            class="full_width"
            v-model="fieldValue"
          />
          <div class="margin-small-top middle">
            <VIcon
              name="attention"
              color="attention"
              x-small
            />
            <span class="margin-small-left">
              {{ fieldOccurrences.length }} linked field occurrences
            </span>
          </div>
        </div>

        <VSpinner
          v-if="isLoading"
          full-screen
        />
      </div>
      <ConfirmationModal ref="confirmationModal" />
    </template>
    <template #footer>
      <VBtn
        color="submit"
        medium
        @click="updateCE"
        :disabled="isUpdating"
      >
        Update
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { FieldOccurrence } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import useStore from '../../store/collectingEvent.js'
import VModal from '@/components/ui/Modal.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const props = defineProps({
  collectingEventId: {
    type: Number,
    required: true
  },

  param: {
    type: Object,
    required: true
  },

  textarea: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])
const store = useStore()
const fieldOccurrences = ref([])
const fieldValue = ref(props.param.value)
const isLoading = ref(true)
const isUpdating = ref(false)
const confirmationModal = ref(null)

const MAX_WITHOUT_WARNING = 10

FieldOccurrence.where({ collecting_event_id: [props.collectingEventId] }).then(
  ({ body }) => {
    fieldOccurrences.value = body
    isLoading.value = false
  }
)

async function updateCE() {
  const ok =
    fieldOccurrences.value.length > MAX_WITHOUT_WARNING
      ? await confirmationModal.value.show({
          title: 'Update collecting event',
          message:
            'This will update the current collecting event. Are you sure you want to proceed?',
          confirmationWord: 'UPDATE',
          okButton: 'Update',
          typeButton: 'submit'
        })
      : true

  if (ok) {
    isUpdating.value = true

    store.update({ [props.param.field]: fieldValue.value }).then(() => {
      isUpdating.value = false
      TW.workbench.alert.create(
        'Collecting event was successfully updated',
        'notice'
      )
      emit('close')
    })
  }
}
</script>
