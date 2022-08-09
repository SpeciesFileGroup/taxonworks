<template>
  <div class="collecting_event_annotator">
    <CeSection
      class="margin-small-bottom"
      :collecting-event="collectingEvent"
      @onSelect="addCollectingEvent"/>
    <div v-if="collectingEvent">
      <h3>Print label</h3>
      <ul
        v-if="identifier"
        class="no_bullets context-menu">
        <li
          v-for="(value, key) in labelTypes"
          :key="value">
          <label>
            <input
              type="radio"
              v-model="label.type"
              :value="key">
            {{ value }}
          </label>
        </li>
      </ul>
      <component
        class="margin-small-top"
        :is="componentName"
        :collecting-event="collectingEvent"
        :identifier="identifier"
        v-model="label"/>
      <button
        class="normal-input button button-submit margin-small-right"
        :disabled="!label.total"
        @click="saveLabel">
        {{ label.id ? 'Update' : 'Create' }}
      </button>
      <button
        type="button"
        class="button normal-input button-default"
        @click="resetLabel">
        New
      </button>
      <table-list
        class="margin-medium-top"
        :list="labels"
        :header="['Label', 'Total', '']"
        :attributes="['label','total']"
        edit
        @edit="setLabel"
        @delete="removeLabel"/>
    </div>
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import TableList from 'components/table_list'
import CeSection from './ceSection'
import TextComponent from './label/TextLabel'
import QRCodeComponent from './label/QRCode'
import {
  LABEL,
  LABEL_QR_CODE,
  LABEL_CODE_128,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  COLLECTION_OBJECT,
  COLLECTING_EVENT
} from 'constants/index.js'
import {
  Label,
  Identifier,
  CollectionObject,
  CollectingEvent
} from 'routes/endpoints'

const LabelTypes = {
  [LABEL]: 'Text',
  [LABEL_QR_CODE]: 'QRCode',
  [LABEL_CODE_128]: 'Barcode'
}

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    BarcodeComponent: QRCodeComponent,
    CeSection,
    TableList,
    TextComponent,
    QRCodeComponent
  },

  computed: {
    componentName () {
      return `${LabelTypes[this.label.type]}Component`
    }
  },

  data () {
    return {
      loadOnMounted: false,
      label: {},
      collectingEvent: undefined,
      labels: [],
      identifier: undefined,
      labelTypes: LabelTypes
    }
  },

  watch: {
    async collectingEvent (newVal) {
      this.labels = newVal
        ? (await Label.where({
            label_object_id: newVal.id,
            label_object_type: COLLECTING_EVENT
          })).body
        : []
    }
  },

  async created () {
    const ceId = (await CollectionObject.find(this.metadata.object_id)).body.collecting_event_id

    Identifier.where({
      identifier_object_id: this.metadata.object_id,
      identifier_object_type: COLLECTION_OBJECT,
      type: IDENTIFIER_LOCAL_CATALOG_NUMBER
    }).then(response => {
      this.identifier = response.body[0]
    })

    if (ceId) {
      this.collectingEvent = (await CollectingEvent.find(ceId)).body
    }

    this.resetLabel()
  },

  methods: {
    resetLabel () {
      this.label = {
        total: undefined,
        text: undefined,
        type: LABEL
      }
    },

    saveLabel () {
      const label = {
        ...this.label,
        label_object_id: this.collectingEvent.id,
        label_object_type: COLLECTING_EVENT
      }

      const saveRequest = label.id
        ? Label.update(label.id, { label })
        : Label.create({ label })

      saveRequest.then(({ body }) => {
        if (label.id) {
          const index = this.labels.findIndex(item => item.id === body.id)

          this.labels[index] = body
        } else {
          this.labels.unshift(body)
        }

        TW.workbench.alert.create('Label was successfully saved.', 'notice')
      })
    },

    setLabel (label) {
      this.label = label
    },

    removeLabel (label) {
      Label.destroy(label.id).then(() => {
        const index = this.labels.findIndex(item => item.id === label.id)

        this.labels.splice(index, 1)
      })
    },

    addCollectingEvent (ce) {
      CollectionObject.update(this.metadata.object_id, { collection_object: { collecting_event_id: ce.id || null } }).then(_ => {
        this.collectingEvent = ce.id ? ce : undefined
      })
    }
  }
}
</script>
