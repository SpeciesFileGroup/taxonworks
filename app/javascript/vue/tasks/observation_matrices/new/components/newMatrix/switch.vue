<template>
  <div class="middle">
    <span class="switch-option horizontal-center-content capitalize">
      <component :is="checked ? 'span' : 'b'">{{ options[1] }}</component>
    </span>
    <div
      title="Lock / Unlock">
      <label class="switch-lock">
        <input
          v-model="checked"
          type="checkbox">
        <span>
          <em class="arrow left"></em>
          <strong></strong>
        </span>
      </label>
    </div>
    <span class="switch-option horizontal-center-content capitalize">
      <component :is="!checked ? 'span' : 'b'">{{ options[0] }}</component>
    </span>
  </div>
</template>

<script>
export default {
  props: {
    options: {
      type: Array,
      required: true
    },
    modelValue: {
      required: true
    }
  },

  emit: ['update:modelValue'],

  computed: {
    checked: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
    .arrow {
      border: solid black;
      border-width: 0 2px 2px 0;
      display: inline-block;
    }

    .left {
      transform: rotate(135deg);
      -webkit-transform: rotate(135deg);
    }

    .switch-option {
      width: 75px;
    }

    .switch-lock input + span em {
      background-color: transparent;
    }

    .switch-lock input + span em:after {
      border: transparent;
    }

    .switch-lock input:checked + span em {
      transform-origin: center;
      transform: rotate(-45deg);
      -webkit-transform: rotate(-45deg);
      left: 26px;
    }

    .switch-lock input:checked + span:before {
      background: #E4ECFA;
    }

</style>
