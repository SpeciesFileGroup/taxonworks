<template>
  <div class="header-cell">
    <label
      class="header-label cursor-pointer ellipsis"
      :title="title">
      <tippy-component
        animation="scale"
        placement="bottom"
        size="small"
        arrow-size="small"
        inertia
        arrow
        content="Hide">
        <template slot="trigger">
          <input
            type="checkbox"
            :value="index"
            v-model="hideColumn">
          {{ title }}
        </template>
      </tippy-component>
    </label>
  </div>
</template>
<script>

import { TippyComponent } from 'vue-tippy'

export default {
  components: { TippyComponent },

  props: {
    title: {
      type: String,
      required: true
    },

    value: {
      type: Array,
      required: true
    },

    index: {
      type: [String, Number],
      required: true
    }
  },

  computed: {
    hideColumn: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>