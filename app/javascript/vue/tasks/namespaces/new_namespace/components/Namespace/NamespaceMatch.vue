<template>
  <div
    v-if="matches.length"
    class="panel content">
    <h3>Match</h3>
    <ul class="no_bullets full_width">
      <li
        v-for="item in matches"
        :key="item.id"
        class="horizontal-left-content middle"
      >
        <span
          class="cursor-pointer"
          @click="getNamespace(item.id)"
          v-html="item.label_html"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { watch, ref } from 'vue'
import { Namespace } from 'routes/endpoints'

export default {
  props: {
    name: {
      type: String,
      required: true
    }
  },

  emits: ['onSelect'],

  setup (props, { emit }) {
    const delay = 1000
    const matches = ref([])
    let requestTimeout

    watch(() => props.name, (currentValue) => {
      clearTimeout(requestTimeout)

      requestTimeout = setTimeout(async () => {
        matches.value = currentValue.trim()
          ? (await Namespace.autocomplete({ term: currentValue })).body
          : []
      }, delay)
    })

    function getNamespace (id) {
      Namespace.find(id).then(({ body }) => {
        emit('onSelect', body)
      })
    }

    return {
      matches,
      getNamespace
    }
  }
}
</script>
