<template>
  <section-panel title="Collecting events">
    <a name="collecting-events"/>
    <ul>
      <li
        v-for="(item, index) in collectingEvents"
        :key="item.id"
        v-if="index < max || showAll">
        <a
          :href="`/collecting_events/${item.id}`"
          v-html="item.object_tag"/>
      </li>
    </ul>
    <template v-if="collectingEvents.length > max">
      <a
        v-if="!showAll"
        class="cursor-pointer"
        @click="showAll = true">Show all
      </a> 
      <a
        v-else
        class="cursor-pointer"
        @click="showAll = false">Show less
      </a>
    </template>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetCollectingEvents } from '../request/resources.js'

export default {
  components: {
    SectionPanel
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      collectingEvents: [],
      max: 10,
      showAll: false
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        GetCollectingEvents([this.otu.id]).then(response => {
          this.collectingEvents = response.body
        })
      },
      immediate: true
    }
  }
}
</script>