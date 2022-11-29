<template>
  <div>
    <ConfirmationModal ref="confirmationModal" />
    <VBtn
      class="circle-button"
      color="primary"
      circle
      :disabled="disabled"
      @click="openModal"
    >
      <VIcon
        name="trash"
        x-small
      />
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject, Metadata } from 'routes/endpoints'
import { COLLECTION_OBJECT } from 'constants/index'
import { humanize } from 'helpers/strings'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'

const CONFIRM_WORD = 'DELETE'
const MAX = 25
const MIN_CONFIRM = 5

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['delete'])
const confirmationModal = ref(null)
const metadata = ref({})

function deleteCOs () {
  let failedCount = 0
  const ids = [...props.ids]
  const destroyedIds = []
  const requests = ids.map(id =>
    CollectionObject.destroy(id)
      .then(_ => destroyedIds.push(id))
      .catch(_ => failedCount++)
  )

  Promise.allSettled(requests).then(_ => {
    const message = failedCount
      ? `Deleted: ${destroyedIds.length} object(s). Failed to delete: ${failedCount}.`
      : `Deleted: ${destroyedIds.length} object(s).`

    TW.workbench.alert.create(message, 'notice')
    emit('delete', destroyedIds)
  })
}

function makeList (title, obj) {
  const entries = Object.entries(obj)

  return entries.length
    ? `<h3>${title}</h3>` + entries.map(([type, count]) => `<li>${humanize(type)}: ${count}</li>`).join('')
    : ''
}

async function openModal () {
  if (props.ids.length > MAX) {
    TW.workbench.alert.create(`Select a maximum of ${MAX} objects to delete.`, 'error')

    return
  }

  metadata.value = (await Metadata.relatedSummary({
    id: props.ids,
    klass: COLLECTION_OBJECT
  })).body

  const ok = await confirmationModal.value.show({
    title: 'Delete collection objects',
    message: `
      This will delete ${props.ids.length} collection objects and their associated determinations and annotations (e.g. Notes).
      <br>
      ${makeList('Related records that will be destroyed:', metadata.value.destroy)}
      ${makeList('Records preventing the destruction of one or more objects exist:', metadata.value.restrict)}
      <br>
      Are you sure you want to proceed?`,
    confirmationWord: props.ids.length >= MIN_CONFIRM ? CONFIRM_WORD : '',
    okButton: 'Delete',
    cancelButton: 'Cancel',
    typeButton: 'delete'
  })

  if (ok) {
    deleteCOs()
  }
}

</script>
