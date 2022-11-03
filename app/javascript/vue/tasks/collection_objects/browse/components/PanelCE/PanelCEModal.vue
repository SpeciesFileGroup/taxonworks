<template>
  <VModal :container-style="{ width: '600px' }">
    <template #header>
      <h3>Collecting event - {{ param.field }}</h3>
    </template>
    <template #body>
      <div>
        <div class="field label-above">
          <label>
            {{ param.field }}
          </label>
          <input
            type="text"
            v-model="fieldValue"
          >
          <span class="margin-small-left">
            <VIcon
              name="attention"
              color="attention"
              x-small
            />
            {{ collectionObjects.length }} linked collection objects
          </span>
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

      <VBtn
        class="margin-small-left"
        color="primary"
        medium
        @click="emit('close')"
      >
        Cancel
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import { useStore } from 'vuex'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import VModal from 'components/ui/Modal.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VSpinner from 'components/spinner.vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'

const props = defineProps({
  collectingEventId: {
    type: Number,
    required: true
  },

  param: {
    type: Object,
    required: true
  }
})

const emit = defineEmits('close')
const store = useStore()
const collectionObjects = ref([])
const fieldValue = ref(props.param.value)
const isLoading = ref(true)
const isUpdating = ref(false)
const confirmationModal = ref(null)

const MAX_WITHOUT_WARNING = 10

CollectionObject.where({ collecting_event_ids: [props.collectingEventId] }).then(({ body }) => {
  collectionObjects.value = body
  isLoading.value = false
})

async function updateCE () {
  const ok = collectionObjects.value.length > MAX_WITHOUT_WARNING
    ? await confirmationModal.value.show({
      title: 'Update collecting event',
      message: 'This will update the current collecting event. Are you sure you want to proceed?',
      confirmationWord: 'UPDATE',
      okButton: 'Update',
      typeButton: 'submit'
    })
    : true

  if (ok) {
    isUpdating.value = true

    store.dispatch(ActionNames.UpdateCollectingEvent, {
      collectingEventId: props.collectingEventId,
      payload: { [props.param.field]: fieldValue.value }
    })
      .then(_ => {
        const coId = store.getters[GetterNames.GetCollectionObject].id

        store.dispatch(ActionNames.LoadDwc, coId)
        store.dispatch(ActionNames.LoadTimeline, coId)

        isUpdating.value = false
        TW.workbench.alert.create('Collecting event was successfully updated', 'notice')
        emit('close')
      })
  }
}

</script>
