<template>
  <button
    type="button"
    class="button button-default button-select margin-small-bottom"
    @click="isOpen = true"
  >
    {{ buttonLabel }}
  </button>

  <v-modal
    v-if="isOpen"
    :container-style="{ width: '600px', height: '70vh' }"
    @close="isOpen = false"
  >
    <template #header>
      <h3>Select Content</h3>
    </template>
    <template #body>
      <smart-selector
        model="contents"
        :extend="['otu', 'topic']"
        @selected="selected"
      />
    </template>
  </v-modal>
</template>

<script>

import VModal from 'components/ui/Modal.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  components: {
    SmartSelector,
    VModal
  },

  data () {
    return {
      isOpen: false
    }
  },

  computed: {
    content: {
      get () {
        return this.$store.getters[GetterNames.GetContentSelected]
      },
      set (value) {
        this.$store.commit(MutationNames.SetContentSelected, value)
      }
    },

    buttonLabel () {
      return this.content
        ? 'Change Content'
        : 'Content'
    }
  },

  methods: {
    selected (content) {
      console.log(content)
      this.content = content
      this.isOpen = false
    }
  }
}
</script>
