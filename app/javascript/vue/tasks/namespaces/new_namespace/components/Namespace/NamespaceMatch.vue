<template>
  <div
    v-if="matches.length"
    class="panel content">
    <h3>Match</h3>
    <ul class="no_bullets">
      <li
        v-for="item in matches"
        :key="item.id"
      >
        {{ item.name }}
        <v-btn
          circle
          color="primary"
          @click="selectNamespace(item)">
          <v-icon
            x-small
            name="pencil"/>
        </v-btn>
      </li>
    </ul>
  </div>
</template>

<script>

import { Namespace } from 'routes/endpoints'
import { watch, ref } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

export default {
  components: {
    VBtn,
    VIcon
  },

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
        matches.value = currentValue
          ? (await Namespace.where({ name: currentValue })).body
          : []
      }, delay)
    })

    function selectNamespace (value) {
      emit('onSelect', value)
    }

    return {
      matches,
      selectNamespace
    }
  }
}
</script>
