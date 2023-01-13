<template>
  <div class="panel">
    <modal
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Confirm delete</h3>
      </template>
      <template #body>
        <div>Are you sure you want to delete {{ descriptor.object_tag }} ?</div>
      </template>
      <template #footer>
        <button
          @click="deleteDescriptor()"
          type="button"
          class="normal-input button button-delete align-end">Delete</button>
      </template>
    </modal>
    <div class="content">
      <div
        v-if="descriptor.id"
        class="flex-separate middle">
        <h3>{{ descriptor.object_tag }}</h3>
        <div class="descriptor-preview-options middle">
          <radial-annotator
            :global-id="descriptor.global_id"/>
          <span
            @click="showModal = true"
            class="circle-button btn-delete"/>
        </div>
      </div>
      <p v-show="descriptor.description">{{ descriptor.description }}</p>
    </div>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import Modal from 'components/ui/Modal.vue'

export default {
  components: {
    RadialAnnotator,
    Modal
  },

  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },

  emits: ['remove'],

  data () {
    return {
      showModal: false
    }
  },

  methods: {
    deleteDescriptor () {
      this.$emit('remove', this.descriptor)
    }
  }
}
</script>

<style lang="scss" scoped>
  .descriptor-preview-options {
    display: flex;
    justify-content: space-between;
  }
</style>
