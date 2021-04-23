<template>
  <div class="middle">
    <label class="switch middle">
      <div class="middle space-between-switch-options">
        <span class="switch-option horizontal-center-content capitalize">{{ options[0] }}</span>
        <span class="switch-option horizontal-center-content capitalize">{{ options[1] }}</span>
      </div>
      <input
        type="checkbox"
        v-model="checked">
      <div class="slider"/>
    </label>
  </div>
</template>

<script>
export default {
  props: {
    options: {
      type: Array,
      required: true
    },
    value: {
      required: true
    }
  },
  computed: {
    checked: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>

<style scoped>

    .space-between-switch-options {
      padding: 4px;
    }
    .switch-option {
      width: 75px;
    }
    .switch input {
      display: none;
    }
    .switch {
      position: relative;
      display: inline-block;
      width: 150px;
      height: 24px;
      justify-content: space-around;
      border-radius: 3px;
      border:1px solid #efefef;
      border-right: 0px;    
      background-color: #efefef;
      box-shadow:inset 0px 1px 4px 0px rgba(0,0,0,0.1); 
    }
    .slider {
      position: absolute;
      cursor: pointer;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      -webkit-transition: .4s;
      transition: .4s;
    }

    .slider:before {
      position: absolute;
      content: "";
      height: 26px;
      width: 75px;
      left: -2px;
      bottom: -2px;
      border-radius: 3px;
      border:1px solid #efefef;
      background-color: #FFF;
      transition: .3s;
    }

    input:checked + .slider:before {
      -webkit-transform: translateX(75px);
      -ms-transform: translateX(75px);
      transform: translateX(75px);
    }

</style>