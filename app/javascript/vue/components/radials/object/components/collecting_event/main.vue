<template>
  <div class="collecting_event_annotator">
    <CeSection
      class="margin-small-bottom"
      :collecting-event="collectingEvent"
      @select="addCollectingEvent"
    />
    <div v-if="collectingEvent">
      <h3>Print label</h3>
      <ul
        v-if="identifier"
        class="no_bullets context-menu"
      >
        <li
          v-for="(_, key) in LABEL_TYPES"
          :key="key"
        >
          <label>
            <input
              type="radio"
              v-model="label.type"
              :value="key"
            />
            {{ key }}
          </label>
        </li>
      </ul>
      <component
        class="margin-small-top"
        :is="LABEL_TYPES[label.type]"
        :collecting-event="collectingEvent"
        :identifier="identifier"
        v-model="label"
      />
      <button
        class="normal-input button button-submit margin-small-right"
        :disabled="!label.total || !label.text"
        @click="saveLabel"
      >
        {{ label.id ? 'Update' : 'Create' }}
      </button>
      <button
        type="button"
        class="button normal-input button-default"
        @click="resetLabel"
      >
        New
      </button>
      <TableList
        class="margin-medium-top"
        :list="list"
        :header="['Label', 'Total', '']"
        :attributes="['label', 'total']"
        edit
        @edit="setLabel"
        @delete="removeLabel"
      />
    </div>
  </div>
</template>

<script setup>
import TableList from '@/components/table_list'
import CeSection from './ceSection'
import TextComponent from './label/TextLabel'
import QRCodeComponent from './label/QRCode'
import { useSlice } from '@/components/radials/composables'
import {
  LABEL,
  LABEL_QR_CODE,
  LABEL_CODE_128,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  COLLECTION_OBJECT,
  COLLECTING_EVENT,
  FIELD_OCCURRENCE
} from '@/constants/index.js'
import {
  Label,
  Identifier,
  CollectionObject,
  FieldOccurrence,
  CollectingEvent
} from '@/routes/endpoints'
import { onBeforeMount, ref, watch } from 'vue'

const LABEL_TYPES = {
  [LABEL]: TextComponent,
  [LABEL_QR_CODE]: QRCodeComponent,
  [LABEL_CODE_128]: QRCodeComponent
}

const TYPES = {
  [FIELD_OCCURRENCE]: {
    service: FieldOccurrence,
    property: 'field_occurrence'
  },
  [COLLECTION_OBJECT]: {
    service: CollectionObject,
    property: 'collection_object'
  }
}

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, removeFromList, addToList } = useSlice({
  radialEmit: props.radialEmit
})

const label = ref({})
const identifier = ref()
const collectingEvent = ref()

watch(collectingEvent, (newVal) => {
  if (newVal)
    Label.where({
      label_object_id: newVal.id,
      label_object_type: COLLECTING_EVENT
    }).then(({ body }) => {
      list.value = body
    })
})

onBeforeMount(async () => {
  const ceId = (await TYPES[props.objectType].service.find(props.objectId)).body
    ?.collecting_event_id

  Identifier.where({
    identifier_object_id: props.objectId,
    identifier_object_type: props.objectType,
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER
  }).then(({ body }) => {
    identifier.value = body[0]
  })

  if (ceId) {
    collectingEvent.value = (await CollectingEvent.find(ceId)).body
  }

  resetLabel()
})

function resetLabel() {
  label.value = {
    total: undefined,
    text: undefined,
    type: LABEL
  }
}

function saveLabel() {
  const payload = {
    label: {
      ...label.value,
      label_object_id: collectingEvent.value.id,
      label_object_type: COLLECTING_EVENT
    }
  }

  const saveRequest = label.value.id
    ? Label.update(label.value.id, payload)
    : Label.create(payload)

  saveRequest.then(({ body }) => {
    addToList(body)
    TW.workbench.alert.create('Label was successfully saved.', 'notice')
  })
}

function setLabel(label) {
  label.value = label
}

function removeLabel(label) {
  Label.destroy(label.id).then(() => {
    removeFromList(label)
    TW.workbench.alert.create('Label was successfully destroyed.', 'notice')
  })
}

function addCollectingEvent(ce) {
  TYPES[props.objectType].service
    .update(props.objectId, {
      [TYPES[props.objectType].property]: { collecting_event_id: ce.id || null }
    })
    .then(() => {
      collectingEvent.value = ce.id ? ce : undefined
    })
}
</script>
