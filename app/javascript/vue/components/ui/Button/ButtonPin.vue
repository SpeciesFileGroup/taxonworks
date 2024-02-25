<template>
  <VBtn
    circle
    :color="pin ? 'destroy' : 'create'"
    @click="pin ? deletePin() : createPin()"
  >
    <VIcon
      small
      color="white"
      name="pin"
    />
  </VBtn>
</template>

<script setup>
import { PinboardItem } from '@/routes/endpoints'
import { ref, watch, onBeforeUnmount, onBeforeMount } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  pinObject: {
    type: Object,
    default: undefined
  },

  objectId: {
    type: [String, Number],
    required: true
  },

  type: {
    type: String,
    required: true
  },

  pluralize: {
    type: Boolean,
    default: true
  },

  section: {
    type: String,
    default: undefined
  }
})

const pin = ref()

watch(
  () => props.pinObject,
  (newVal) => {
    pin.value = newVal
  },
  { immediate: true }
)

watch(() => props.objectId, retrievePinnedObject, { immediate: true })

onBeforeMount(() => {
  document.addEventListener('pinboard:remove', clearPin)
})

onBeforeUnmount(() => {
  document.removeEventListener('pinboard:remove', clearPin)
})

function clearPin(event) {
  if (pin.value?.id === event.detail.id) {
    pin.value = undefined
  }
}

function retrievePinnedObject() {
  const section = document.querySelector(
    `[data-pinboard-section="${
      props.section
        ? props.section
        : `${props.type}${props.pluralize ? 's' : ''}`
    }"] [data-pinboard-object-id="${props.objectId}"]`
  )

  pin.value = section
    ? {
        id: section.getAttribute('data-pinboard-item-id'),
        type: props.type
      }
    : undefined
}

function createPin() {
  const payload = {
    pinboard_item: {
      pinned_object_id: props.objectId,
      pinned_object_type: props.type,
      is_inserted: true
    }
  }

  PinboardItem.create(payload).then(({ body }) => {
    pin.value = body
    TW.workbench.pinboard.addToPinboard(body, true)
    TW.workbench.alert.create(
      'Pinboard item was successfully created.',
      'notice'
    )
  })
}

function deletePin() {
  PinboardItem.destroy(pin.value.id).then(() => {
    TW.workbench.pinboard.removeItem(pin.value.id)
    TW.workbench.alert.create(
      'Pinboard item was successfully destroyed.',
      'notice'
    )
    pin.value = undefined
  })
}
</script>
