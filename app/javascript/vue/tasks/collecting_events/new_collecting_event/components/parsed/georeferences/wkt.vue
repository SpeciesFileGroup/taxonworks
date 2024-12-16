<template>
  <div>
    <button
      :disabled="disabled"
      class="button normal-input button-default"
      @click="setModalView(true)"
    >
      WKT coordinates
    </button>
    <VModal
      v-if="show"
      @close="setModalView(false)"
    >
      <template #header>
        <slot name="header"><h3>Create WKT georeference</h3></slot>
      </template>
      <template #body>
        <div class="field label-above">
          <label>WKT data</label>
          <textarea
            class="full_width"
            rows="8"
            v-model="wkt"
            ref="textArea"
          />
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="normal-input button button-submit"
          @click="createShape"
        >
          Add
        </button>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import { GEOREFERENCE_WKT } from '@/constants/index.js'
import { nextTick, ref } from 'vue'

const props = defineProps({
  type: {
    type: String,
    default: GEOREFERENCE_WKT
  },
  idKey: {
    type: String,
    default: 'tmpId'
  },
  idGenerator: {
    type: Function,
    default: () => Math.random().toString(36).substr(2, 5)
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['create'])

const show = ref(false)
const wkt = ref(undefined)
const textArea = ref(null)

function createShape() {
  emit('create', {
      [props.idKey]: (props.idGenerator)(),
      wkt: wkt.value,
      type: props.type
    })
  show.value = false
}

function resetShape() {
  wkt.value = undefined
}

function setModalView(value) {
  resetShape()
  show.value = value
  if (value) {
    nextTick(() => {
      textArea.value.focus()
    })
  }
}
</script>
