<template>
  <div>
    <VSpinner
      v-if="isSearching"
      :show-legend="false"
      :logo-size="{
        width: '14px',
        height: '14px'
      }"
    />
    <button
      type="button"
      class="button normal-input button-default"
      @click="cloneLabel"
      :disabled="!bufferedCollectingEvent"
    >
      Clone from specimen
    </button>
    <VModal
      v-if="isModalVisible"
      @close="closeModal"
    >
      <template #header>
        <h3>Existing collecting events</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="ce in list"
            :key="ce.id"
            class="separate-bottom"
          >
            <label>
              <input
                type="radio"
                :value="ce"
                v-model="selectedCE"
              />
              <span v-html="ce.object_tag" />
            </label>
          </li>
          <button
            type="button"
            :disabled="!selectedCE"
            class="button normal-input button-default"
            @click="setCE(selectedCE)"
          >
            Set collecting event
          </button>
        </ul>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { CollectingEvent } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useStore from '../../store/collectingEvent.js'

const props = defineProps({
  bufferedCollectingEvent: {
    type: String,
    default: ''
  }
})

const collectingEvent = defineModel({
  type: Object,
  required: true
})

const isModalVisible = ref(false)
const list = ref([])
const isSearching = ref(false)
const selectedCE = ref()
const store = useStore()

watch(isSearching, (newVal) => {
  if (!newVal && list.value.length) {
    isModalVisible.value = true
  } else {
    collectingEvent.value.verbatim_label = props.bufferedCollectingEvent
  }
})

function cloneLabel() {
  isSearching.value = true
  CollectingEvent.where({
    verbatim_label: props.bufferedCollectingEvent
  }).then(({ body }) => {
    list.value = body.filter((ce) => ce.id !== collectingEvent.value.id)
    isSearching.value = false

    CollectingEvent.parseVerbatimLabel({
      verbatim_label: props.bufferedCollectingEvent
    }).then(({ body }) => {
      const parsed = {
        ...body.date,
        ...body.geo.verbatim,
        ...body.elevation,
        ...body.collecting_method
      }

      if (Object.keys(parsed).length) {
        Object.assign(collectingEvent.value, {
          ...parsed,
          isUnsaved: true
        })
      }
    })
  })
}

function setCE(ce) {
  store.load(ce.id)
  closeModal()
}

function closeModal() {
  isModalVisible.value = false
  selectedCE.value = false
}
</script>
