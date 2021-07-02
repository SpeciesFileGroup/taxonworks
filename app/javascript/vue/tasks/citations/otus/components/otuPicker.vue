<template>
  <div>
    <div class="flex-wrap-row middle">
      <button
        class="button button-default normal-input"
        @click="showModal = true"
      >
        {{ otu ? 'Change OTU' : 'Select OTU' }}
      </button>
    </div>
    <modal
      @close="showModal = false"
      v-if="showModal">
      <template #header>
        <h3>Select OTU</h3>
      </template>
      <template #body>
        <autocomplete
          url="/otus/autocomplete"
          min="2"
          param="term"
          placeholder="Find OTU"
          @getItem="loadOtu($event.id)"
          label="label"
          :autofocus="true"/>
      </template>
    </modal>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { Otu } from 'routes/endpoints'

import Autocomplete from 'components/ui/Autocomplete.vue'
import Modal from 'components/ui/Modal.vue'

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
    otu () {
      return this.$store.getters[GetterNames.GetOtuSelected]
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const otuId = urlParams.get('otu_id')

    if (/^\d+$/.test(otuId)) {
      this.loadOtu(otuId)
    }
  },

  methods: {
    loadOtu (id) {
      Otu.find(id).then(response => {
        this.$store.commit(MutationNames.SetOtuSelected, response.body)
        this.showModal = false
      })
    }
  }
}
</script>
