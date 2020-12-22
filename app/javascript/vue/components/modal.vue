<template>
  <transition name="modal">
    <div
      class="modal-mask"
      @click="closeModal('out')"
      @key.esc="closeModal('esc')">
      <div class="modal-wrapper">
        <div
          class="modal-container"
          :class="containerClass"
          :style="containerStyle"
          @click.stop>
          <div class="modal-header">
            <div
              class="modal-close"
              @click="closeModal('x')"/>
            <slot name="header">
              default header
            </slot>
          </div>
          <div class="modal-body">
            <slot name="body">
              default body
            </slot>
          </div>
          <div class="modal-footer">
            <slot name="footer"/>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  props: {
    containerClass: {
      type: Object,
      default: () => {
        return {}
      }
    },
    containerStyle: {
      type: Object,
      default: () => {
        return {}
      }
    }
  },
  mounted: function () {
    document.addEventListener('keydown', (e) => {
      if (e.keyCode === 27) {
        this.closeModal('esc')
      }
    })
  },
  methods: {
    closeModal (eventName) {
      this.$emit('close')
      this.$emit(`close-${eventName}`)
    }
  }
}
</script>
