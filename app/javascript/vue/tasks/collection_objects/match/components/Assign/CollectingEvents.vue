<template>
  <div class="panel content">
    <h2>Collecting events</h2>
    <spinner-component
      v-if="isSaving"
      legend="Saving..."/>
    <fieldset>
      <legend>Collecting events</legend>
      <smart-selector
        class="margin-medium-bottom"
        model="collecting_events"
        pin-section="CollectingEvents"
        pin-type="CollectingEvent"
        target="CollectionObject"
        @selected="setCollectingEvent"
      />
      <p
        v-if="collectingEvent"
        class="horizontal-left-content">
        <span v-html="collectingEventLabel"/>
        <span 
          class="button btn-undo circle-button button-default"
          @click="setCollectingEvent(undefined)"/>
      </p>
    </fieldset>
    <div class="margin-medium-top">
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!validateFields"
        @click="addCollectingEvent()">
        Set
      </button>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SpinnerComponent from 'components/spinner'
import { UpdateCollectionObject } from '../../request/resources'

export default {
  components: {
    SmartSelector,
    SpinnerComponent
  },
  props: {
    ids: {
      type: Array,
      required: true
    }
  },
  computed: {
    collectingEventLabel () {
      if(!this.collectingEvent) return
      return this.collectingEvent.hasOwnProperty('object_tag') ? this.collectingEvent.object_tag : this.collectingEvent.html_label
    },
    validateFields () {
      return this.collectingEvent && this.ids.length
    }
  },
  data () {
    return {
      collectingEvent: undefined,
      isSaving: false,
      maxPerCall: 1 
    }
  },
  methods: {
    setCollectingEvent (ce) {
      this.collectingEvent = ce
    },
    addCollectingEvent (position = 0) {
      let promises = []

      for(let i = 0; i < this.maxPerCall; i++) {
        if(position < this.ids.length) {
          promises.push(new Promise((resolve, reject) => {
            UpdateCollectionObject(this.ids[position], { collecting_event_id: this.collectingEvent.id }).then(response => {
              resolve()
            }, () => {
              resolve()
            })
          }))
          position++
        }
      }
      Promise.all(promises).then(response => {
        if(position < this.ids.length)
          this.addCollectingEvent(position)
        else {
          this.isSaving = false
          TW.workbench.alert.create('Collection objects was successfully updated.', 'notice')
        }
      })
    },
  }
}
</script>
