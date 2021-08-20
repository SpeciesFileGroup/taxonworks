<template>
  <div class="save-countdown">
    <transition
      name="countdown-animation-bar"
      @after-enter="emitSave">
      <div
        v-if="isCountingDown"
        class="bar"/>
    </transition>

    <div
      v-if="!isCountingDown"
      class="bar"
      :class="{ 'saving': isSaving, 'saved-at-least-once': savedAtLeastOnce }"/>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String,
      required: true
    }
  },

  data () {
    return {
      isCountingDown: false,
      isSaving: false,
      savedAtLeastOnce: false,
    }
  },

  watch: {
    value () {
      this.isCountingDown = true
    }
  },

  methods: {
    emitSave () {
      this.isCountingDown = false
      this.$emit('save', true)
    }
  }
}
</script>
<style lang="scss">
  .save-countdown {
    .bar {
      background-color: transparent;
      left: 0;
      height: 3px;
      position: absolute;
      transform-origin: 0 50%;
      transition: background-color 250ms;
      bottom: 0;
      right: 0;
      z-index: 1;
    }

    .countdown-animation-bar-enter-active {
      animation: saveCountdown 3333ms linear;
    }

    .saved-at-least-once {
      background-color: green;
    }

    .saving {
      background-color: yellow;
    }
  }


  @keyframes saveCountdown {
    from {
      background-color: red;
      transform: scaleX(0);
    }
    to {
      background-color: red;
      transform: scaleX(1);
    }
  }
</style>
