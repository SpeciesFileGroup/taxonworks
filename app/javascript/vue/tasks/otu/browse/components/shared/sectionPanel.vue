<template>
  <div class="panel basic-information">
    <spinner-component v-if="spinner" />
    <div
      v-help.section.status
      :class="{ [status]: status }"
      class="header flex-separate middle">
      <a
        v-if="anchor"
        :name="anchor"
        class="anchor"
      />
      <div>
        <span class="section-title">{{ title }}</span>
        <slot name="title" />
      </div>
      <div class="horizontal-left-content">
        <div
          v-help.section.options.drag
          data-icon="w_scroll-v"
          class="option-box button-default cursor-pointer handle"
        />
        <div
          class="option-box button-default cursor-pointer"
          v-help.section.options.filter
          @click="$emit('menu')"
        >
          <div class="hamburger-menu">
            <div class="hamburger-menu-bar" />
            <div class="hamburger-menu-bar" />
            <div class="hamburger-menu-bar" />
          </div>
        </div>
      </div>
    </div>
    <div class="content">
      <slot v-if="!hidden" />
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
    },
    status: {
      type: String,
      default: 'unknown'
    },
    anchor: {
      type: String,
      default: undefined
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

  .unknown {
    border-left-color: #bbbbbb;
  }

  .stable {
    border-left-color: #fdbd41;
  }

  .prototype {
    border-left-color: #fc615d;
  }
</style>
