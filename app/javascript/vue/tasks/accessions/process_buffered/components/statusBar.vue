<template>
  <div class="panel basic-information">
    <div
      class="header flex-wrap-column"
      :class="{ 'validation-warning': (settings.lastSave < settings.lastChange) }">
      <h3>Collecting event</h3>
      <ul class="no_bullets"> 
        <li
          v-for="item in setStatus()"
          data-icon="warning">
          {{ item }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { GetCollectingEvent } from '../request/resource'

export default {
  computed: {
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    },
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    settings () {
      return this.$store.getters[GetterNames.GetSettings]
    }
  },
  data () {
    return {
      count: undefined
    }
  },
  watch: {
    collectingEvent: {
      handler (newVal) {
        if (newVal.id) {
          this.currentCEUsed()
        }
      },
      deep: true
    }
  },
  methods: {
    setStatus () {
      let notifications = []

      if (!this.collectionObject.id) {
        notifications.push('New collection event')
      } else {
        notifications.push('Current collection event')
      }

      if (this.settings.lastSave < this.settings.lastChange) {
        notifications.push('Unsaved changes')
      }
      if (this.count) {
        notifications.push(`Current used in: ${this.count}`)
      }

      return notifications
    },
    currentCEUsed () {
      GetCollectingEvent(this.collectingEvent.id).then(response => {
        this.count = response.length
      })
    }
  }
}
</script>
