<template>
  <div>
    <v-btn
      medium
      color="primary"
      @click="setModalView(true)">
      Descriptors
    </v-btn>
    <v-modal
      v-if="isVisible"
      @close="setModalView(false)"
      :containerStyle="{ width: '800px' }">
      <template #header>
        <h3>Descriptors</h3>
      </template>
      <template #body>
        <ul class="matrix-row-coder__descriptor-menu flex-wrap-column no_bullets">
          <li 
            v-for="descriptor in descriptors"
            :key="descriptor.id">
            <div>
              <a
                class="matrix-row-coder__descriptor-item"
                :data-icon="observationsCount(descriptor.id) ? 'ok' : false"
                @click="zoomDescriptor(descriptor.id)"
                v-html="descriptor.title"/>
            </div>
          </li>
        </ul>
      </template>
    </v-modal>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const computed = mapState({
  title: state => state.taxonTitle,
  descriptors: state => state.descriptors
})

export default {
  components: {
    VModal,
    VBtn
  },

  data () {
    return {
      isVisible: false
    }
  },

  computed,

  methods: {
    zoomDescriptor (descriptorId) {
      const top = document.querySelector(`[data-descriptor-id="${descriptorId}"]`).getBoundingClientRect().top + window.pageYOffset - 80

      window.scrollTo({ top })
      this.setModalView(false)
    },

    observationsCount (descriptorId) {
      return this.$store.getters[GetterNames.GetObservationsFor](descriptorId).find(item => item.id != null)
    },

    setModalView (value) {
      this.isVisible = value
    }
  }
}
</script>