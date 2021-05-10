<template>
  <div>
    <div class="flex-wrap-row middle">
      <button
        class="button button-default normal-input"
        @click="showModal = true"
        v-if="source">Change source
      </button>
      <button
        class="button button-default normal-input"
        @click="showModal = true"
        v-else>Select source
      </button>
    </div>
    <modal
      @close="showModal = false"
      v-if="showModal">
      <h3 slot="header">Select source</h3>
      <div
        slot="body"
        id="source_panel">
        <autocomplete
          url="/sources/autocomplete"
          min="2"
          param="term"
          placeholder="Find source"
          @getItem="loadSource"
          label="label"
          :autofocus="true"/>
      </div>
    </modal>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { Source } from 'routes/endpoints'
import Autocomplete from 'components/ui/Autocomplete.vue'
import Modal from 'components/modal.vue'

export default {
  data () {
    return {
      showModal: false
    }
  },

  components: {
    Autocomplete,
    Modal
  },

  computed: {
    source () {
      return this.$store.getters[GetterNames.GetSourceSelected]
    }
  },

  methods: {
    loadSource (item) {
      Source.find(item.id).then(response => {
        this.$store.commit(MutationNames.SetSourceSelected, response.body)
        this.showModal = false
      })
    }
  }
}
</script>
