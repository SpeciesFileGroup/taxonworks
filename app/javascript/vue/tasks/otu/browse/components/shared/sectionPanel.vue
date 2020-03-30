<template>
  <div>
    <spinner-component v-if="spinner"/>
    <div class="panel">
      <div class="content">
        <div>
          <div class="flex-separate">
            <div>
              <span class="section-title">{{ title }}</span>
              <slot name="title">
              </slot>
            </div>
            <div class="horizontal-left-content">
              <div
                class="option-box button-default cursor-pointer"
                @click="hidden = !hidden"
                :data-icon="hidden ? 'w_expand' : 'w_contract'"/>
              <div
                data-icon="w_scroll-v"
                class="option-box button-default cursor-pointer handle"/>
              <div
                class="option-box button-default cursor-pointer"
                @click="$emit('menu')">
                <div class="hamburger-menu">
                  <div class="hamburger-menu-bar"/>
                  <div class="hamburger-menu-bar"/>
                  <div class="hamburger-menu-bar"/>
                </div>
              </div>
            </div>
          </div>
        </div>
        <slot v-if="!hidden"></slot>
      </div>
    </div>
  </div>
</template>

<script>
import SpinnerComponent from 'components/spinner'
export default {
  components: {
    SpinnerComponent
  },
  props: {
    title: {
      type: String,
      default: ''
    },
    spinner: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      hidden: false
    }
  }
}
</script>
<style scoped>
  .option-box {
    position: relative;
    width: 22px;
    height: 22px;
    margin:0 auto;
    margin-left: 4px;
    padding: 0px;
    background-position: center;
    background-size: 14px;
  }
  .hamburger-menu {
    position: absolute;
    left:50%;
    top:50%;
    transform: translate(-50%, -50%);
  }
  .hamburger-menu-bar {
    width: 14px;
    height: 2px;
    background-color: #FFFFFF;
    border-radius: 2px;
    margin: 2px 0;
  }
</style>
