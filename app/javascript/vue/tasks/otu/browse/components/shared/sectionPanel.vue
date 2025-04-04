<template>
  <div class="panel basic-information">
    <VSpinner v-if="spinner" />
    <a
      :name="linkName"
      class="anchor"
    />
    <div
      v-help.section.status
      :class="{ [status]: status }"
      class="header flex-separate middle"
    >
      <div>
        <h3 class="section-title">{{ title }}</h3>
        <slot name="title" />
      </div>
      <div class="horizontal-left-content">
        <div
          v-help.section.options.drag
          data-icon="w_scroll-v"
          class="option-box button-default circle-button cursor-pointer handle"
        />
        <button
          type="button"
          class="option-box cursor-pointer circle-button"
          :class="{ 'button-default': menu }"
          :disabled="!menu"
          v-help.section.options.filter
          @click="emit('menu')"
        >
          <div class="hamburger-menu">
            <div class="hamburger-menu-bar" />
            <div class="hamburger-menu-bar" />
            <div class="hamburger-menu-bar" />
          </div>
        </button>
      </div>
    </div>
    <div class="content">
      <slot v-if="!hidden" />
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner'
import { computed, ref } from 'vue'

const props = defineProps({
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
  name: {
    type: String,
    default: undefined
  },
  menu: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['menu'])

const linkName = computed(() => props.name || props.title)
const hidden = ref(false)
</script>

<style scoped>
.option-box {
  position: relative;
  width: 24px;
  height: 24px;
  margin: 0 auto;
  margin-left: 4px;
  padding: 0px;
  background-position: center;
  background-size: 14px;
  border: 0px;
}
.hamburger-menu {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
}
.hamburger-menu-bar {
  width: 14px;
  height: 2px;
  background-color: #ffffff;
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

.basic-information {
  border-top-left-radius: 0px;
}
</style>
