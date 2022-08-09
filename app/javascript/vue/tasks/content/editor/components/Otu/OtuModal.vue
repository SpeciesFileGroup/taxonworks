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
    @close="isOpen = false"
    :container-style="{ width: '600px', height: '70vh' }"
  >
    <template #header>
      <h3>Select OTU</h3>
    </template>
    <template #body>
      <smart-selector
        model="otus"
        target="Content"
        klass="Content"
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
    otu: {
      get () {
        return this.$store.getters[GetterNames.GetOtuSelected]
      },
      set (value) {
        this.$store.commit(MutationNames.SetOtuSelected, value)
      }
    },

    buttonLabel () {
      return this.otu
        ? 'Change OTU'
        : 'OTU'
    }
  },

  methods: {
    selected (otu) {
      this.otu = otu
      this.isOpen = false
    }
  }
}
</script>
