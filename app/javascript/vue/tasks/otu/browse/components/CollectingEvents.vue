<template>
  <div
    class="panel content"
    v-if="collectingEvents.length">
    <h3>Collecting events</h3>
    <ul>
      <li v-for="item in collectingEvents">
        <span v-html="item.object_tag"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetCollectingEvents } from '../request/resources.js'

export default {
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      collectingEvents: []
    }
  },
  watch: {
    otu(newVal) {
      GetCollectingEvents([this.otu.id]).then(response => {
        this.collectingEvents = response.body
      })
    }
  }
}
</script>