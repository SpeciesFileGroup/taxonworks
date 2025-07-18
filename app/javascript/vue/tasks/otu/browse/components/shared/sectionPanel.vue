<template>
  <BlockLayout
    :anchor="linkName"
    :header-class="status"
  >
    <template #header>
      <h3
        v-help.section.status
        class="section-title"
      >
        {{ title }}
      </h3>
    </template>

    <template #options>
      <div
        v-help.section.options.drag
        class="option-box button-default circle-button cursor-pointer handle"
      >
        <VIcon
          name="scrollV"
          x-small
        />
      </div>
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
    </template>

    <template #body>
      <VSpinner v-if="spinner" />
      <slot v-if="!hidden" />
    </template>
  </BlockLayout>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner'
import { computed, ref } from 'vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

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

<style>
#browse-otu {
  .option-box {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
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
}
</style>
