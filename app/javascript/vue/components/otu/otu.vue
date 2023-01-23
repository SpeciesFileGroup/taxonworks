<template>
  <div class="otu-radial">
    <VBtn
      :title="redirect ? 'Browse OTUs' : 'OTU quick forms'"
      :color="[emptyList ? 'create' : redirect ? 'primary' : 'radial']"
      circle
      @click="openApp()"
      @contextmenu.prevent="openApp(true)"
    >
      <VIcon
        :name="redirect ? 'radialOtuRedirect' : 'radialObject'"
        x-small
      />
    </VBtn>
    <modal
      @close="modalOpen = false"
      v-if="modalOpen"
    >
      <template #header>
        <h3>
          <span v-if="list.length">
            <span v-html="taxonName" /> is linked to {{ list.length }} Otus, go
            to:
          </span>
          <span v-else>
            <span v-html="taxonName" /> is not linked to an OTU
          </span>
        </h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="item in list"
            :key="item.id"
          >
            <a
              href="#"
              @click="processCall(item)"
              v-html="item.object_tag"
            />
          </li>
        </ul>
        <spinner
          v-if="creatingOtu"
          legend="Creating Otu..."
        />
      </template>
    </modal>
    <otu-radial
      ref="annotator"
      type="graph"
      :show-bottom="false"
      :global-id="globalId"
    />
  </div>
</template>

<script>
import Modal from 'components/ui/Modal.vue'
import Spinner from 'components/spinner.vue'
import OtuRadial from 'components/radials/object/radial'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { Otu, TaxonName } from 'routes/endpoints'

export default {
  components: {
    Modal,
    Spinner,
    OtuRadial,
    VBtn,
    VIcon
  },

  props: {
    objectId: {
      type: [String, Number],
      required: false
    },

    otu: {
      type: Object,
      default: undefined
    },

    taxonName: {
      type: String,
      default: ''
    },

    redirect: {
      type: Boolean,
      default: true
    },

    klass: {
      type: String,
      default: undefined
    }
  },

  computed: {
    emptyList() {
      return !this.list.length
    }
  },

  data() {
    return {
      globalId: '',
      modalOpen: false,
      creatingOtu: false,
      loaded: false,
      list: []
    }
  },
  mounted() {
    if (!this.otu && this.objectId) {
      this.getOtuList()
    } else {
      this.list.push(this.otu)
      this.loaded = true
    }
    document.addEventListener('vue-otu:created', (event) => {
      if (this.objectId === event.detail.id) {
        this.list = event.detail.list
      }
    })
  },
  methods: {
    getOtuList() {
      if (this.klass === 'Otu') {
        Otu.find(this.objectId).then((response) => {
          this.list.push(response.body)
          this.loaded = true
        })
      } else {
        TaxonName.otus(this.objectId).then((response) => {
          this.loaded = true
          this.list = response.body
        })
      }
    },

    openApp(newTab = false) {
      if (this.loaded) {
        if (this.emptyList) {
          const otu = { taxon_name_id: this.objectId }
          this.creatingOtu = true

          Otu.create({ otu }).then((response) => {
            this.list.push(response.body)
            this.sendCreatedEvent()
            this.processCall(response.body, newTab)
          })
        } else if (this.list.length === 1) {
          this.processCall(this.list[0], newTab)
        } else {
          this.modalOpen = true
        }
      }
    },

    openRadial(otu) {
      this.globalId = otu.global_id
      this.$nextTick(() => {
        this.$refs.annotator.openRadialMenu()
      })
    },

    sendCreatedEvent() {
      const event = new CustomEvent('vue-otu:created', {
        detail: {
          id: this.objectId,
          list: this.list
        }
      })
      document.dispatchEvent(event)
    },

    processCall(otu, newTab) {
      if (this.redirect) {
        this.redirectTo(otu.id, newTab)
      } else {
        this.openRadial(otu)
      }
    },

    redirectTo(id, newTab = false) {
      window.open(`/tasks/otus/browse/${id}`, `${newTab ? '_blank' : '_self'}`)
    }
  }
}
</script>
<style lang="scss">
.otu-radial {
  .circle-count {
    bottom: -2px !important;
  }
}
</style>
