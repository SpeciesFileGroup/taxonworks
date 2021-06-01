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
        class="normal-input button button-submit"
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

const LabelTypes = {
  Label: 'Text',
  'Label::QrCode': 'QRCode',
  'Label::Code128': 'Barcode'
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
      if (newVal) {
        this.labels = (await this.getList('/labels.json', {
          params: {
            label_object_id: newVal.id,
            label_object_type: 'CollectingEvent'
          }
        })).body
      } else {
        this.labels = []
      }
    }
  },
  async created () {
    const ceId = (await (this.getList(`/collection_objects/${this.metadata.object_id}.json`))).body.collecting_event_id

    this.getList('/identifiers.json', {
      params: {
        identifier_object_id: this.metadata.object_id,
        identifier_object_type: 'CollectionObject',
        type: 'Identifier::Local::CatalogNumber'
      }
    }).then(response => {
      this.identifier = response.body[0]
    })

    if (ceId) {
      this.collectingEvent = (await this.getList(`/collecting_events/${ceId}.json`)).body
    }

    this.resetLabel()
  },
  methods: {
    resetLabel () {
      this.label = {
        total: undefined,
        text: undefined,
        type: 'Label'
      }
    },
    saveLabel () {
      const ceData = {
        label_object_id: this.collectingEvent.id,
        label_object_type: 'CollectingEvent'
      }

      if (this.label?.id) {
        this.update(`/labels/${this.label.id}.json`, { label: Object.assign({}, this.label, ceData) }).then(response => {
          const updatedLabel = response.body
          const index = this.labels.findIndex(item => item.id === updatedLabel.id)

          this.$set(this.labels, index, updatedLabel)
          TW.workbench.alert.create('Label was successfully updated.', 'notice')
        })
      } else {
        this.create('/labels.json', { label: Object.assign({}, this.label, ceData) }).then(response => {
          this.labels.unshift(response.body)
          TW.workbench.alert.create('Label was successfully created.', 'notice')
        })
      }
    },
    setLabel(label) {
      this.label = label
    },
    removeLabel (label) {
      this.destroy(`/labels/${label.id}.json`).then(() => {
        const index = this.labels.findIndex(item => item.id === label.id)

        this.labels.splice(index, 1)
      })
    },
    addCollectingEvent (ce) {
      this.update(`/collection_objects/${this.metadata.object_id}`, { collection_object: { collecting_event_id: ce.id || null } }).then(response => {
        this.collectingEvent = ce.id ? ce : undefined
      })
    }
  }
}
</script>
