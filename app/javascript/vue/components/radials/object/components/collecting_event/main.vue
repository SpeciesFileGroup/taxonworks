<template>
  <div class="collecting_event_annotator">
    <CeSection
      class="margin-small-bottom"
      :collecting-event="collectingEvent"
      @onSelect="addCollectingEvent"/>
    <div v-if="collectingEvent">
      <h3>Print label</h3>
      <div class="flex-separate margin-medium-bottom middle">
        <div>
          <button
            @click="copyLabel"
            class="button normal-input button-default"
            type="button"
            :disabled="isEmpty">
            Copy verbatim label
          </button>
        </div>
        <div class="horizontal-right-content middle">
          <label>Que to print
            <input
              class="que-input"
              :disabled="!(label.text && label.text.length)"
              size="5"
              v-model="label.total"
              type="number">
          </label>
          <a
            v-if="label.id && label.total > 0"
            target="blank"
            :href="`/tasks/labels/print_labels?label_id=${label.id}`">Preview
          </a>
        </div>
      </div>
      <textarea
        class="full_width margin-small-bottom"
        v-model="label.text"
        cols="45"
        rows="12"/>
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
      <display-list
        class="margin-medium-top"
        :list="labels"
        label="text"
        edit
        @edit="setLabel"
        @delete="removeLabel"/>
    </div>
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import DisplayList from 'components/displayList'
import CeSection from './ceSection'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    CeSection,
    DisplayList
  },
  computed: {
    isEmpty () {
      return !this.collectingEvent?.verbatim_label
    }
  },
  async created () {
    const ceId = (await (this.getList(`/collection_objects/${this.metadata.object_id}.json`))).body.collecting_event_id

    if (ceId) {
      this.collectingEvent = (await this.getList(`/collecting_events/${ceId}.json`)).body
    }

    this.resetLabel()
  },
  data () {
    return {
      loadOnMounted: false,
      label: {},
      collectingEvent: undefined,
      labels: []
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
  methods: {
    resetLabel () {
      this.label = {
        total: undefined,
        text: undefined
      }
    },
    copyLabel () {
      this.label.text = this.collectingEvent.verbatim_label
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
