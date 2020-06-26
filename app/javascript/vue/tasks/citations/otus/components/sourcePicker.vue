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
      v-if="showModal"
      @sourcepicker="loadSource">
      <h3 slot="header">Select source</h3>
      <div
        slot="body"
        id="source_panel">
        <autocomplete
          url="/sources/autocomplete"
          min="2"
          param="term"
          placeholder="Find source"
          event-send="sourcepicker"
          label="label"
          :autofocus="true"/>
      </div>
    </modal>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import Autocomplete from 'components/autocomplete.vue'
import Modal from 'components/modal.vue'
import AjaxCall from 'helpers/ajaxCall'

export default {
  data: function () {
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
    loadSource: function (item) {
      AjaxCall('get', `/sources/${item.id}.json`).then(response => {
        this.$store.commit(MutationNames.SetSourceSelected, response.body)
        this.showModal = false
      })
    }
  }
}
</script>
