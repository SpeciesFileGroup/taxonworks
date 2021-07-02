<template>
  <div>
    <modal
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Confirm</h3>
      </template>
      <template #body>
        <div>Are you sure you want to create a new taxon name? All unsaved changes will be lost.</div>
      </template>
      <template #footer>
        <button
          id="confirm-create-newtaxonname"
          @click="reloadPage()"
          type="button"
          class="normal-input button button-default">New
        </button>
      </template>
    </modal>
    <button
      type="button"
      class="normal-input button button-default"
      v-hotkey="shortcuts"
      @click="createNew()">New
    </button>
  </div>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { RouteNames } from 'routes/routes'
import Modal from 'components/ui/Modal.vue'
import PlatformKey from 'helpers/getMacKey'

export default {
  components: {
    Modal
  },
  computed: {
    unsavedChanges () {
      return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
    },
    getParent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    getTaxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    shortcuts () {
      const keys = {}

      keys[`${PlatformKey()}+p`] = this.createNewWithParent
      keys[`${PlatformKey()}+d`] = this.createNewWithChild
      keys[`${PlatformKey()}+n`] = this.createNew

      return keys
    }
  },
  data () {
    return {
      showModal: false,
      url: RouteNames.NewTaxonName
    }
  },

  watch: {
    showModal (newVal) {
      if (newVal) {
        this.$nextTick(() => {
          document.querySelector('#confirm-create-newtaxonname').focus()
        })
      }
    }
  },

  methods: {
    reloadPage() {
      window.location.href = this.url
      this.url = RouteNames.NewTaxonName
    },
    loadWithParent() {
      return ((this.getParent && this.getParent.hasOwnProperty('id')) ? `${RouteNames.NewTaxonName}?parent_id=${this.getParent.id}` : RouteNames.NewTaxonName)
    },
    createNew (newUrl = this.url) {
      this.url = newUrl
      if (this.unsavedChanges) {
        this.showModal = true
      } else {
        this.reloadPage()
      }
    },
    createNewWithChild() {
      this.createNew((this.getTaxon.id ? `${RouteNames.NewTaxonName}?parent_id=${this.getTaxon.id}` : RouteNames.NewTaxonName))
    },
    createNewWithParent() {
      this.createNew((this.getParent && this.getParent.hasOwnProperty('id') ? `${RouteNames.NewTaxonName}?parent_id=${this.getParent.id}` : RouteNames.NewTaxonName))
    },
    getMacKey: function () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    }
  }
}
</script>
