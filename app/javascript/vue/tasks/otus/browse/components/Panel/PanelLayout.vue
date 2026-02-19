<template>
  <BlockLayout
    :anchor="linkName"
    :header-class="status"
  >
    <template #header>
      <h3>
        {{ title }}
      </h3>
    </template>

    <template #options>
      <VBtn
        v-if="menu"
        circle
        color="primary"
        v-help.section.options.filter
        @click="emit('menu')"
      >
        <VIcon
          name="hamburger"
          x-small
        />
      </VBtn>
    </template>

    <template #body>
      <VSkeleton
        v-if="spinner"
        v-bind="skeleton"
      />
      <slot v-if="!spinner" />
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VSkeleton from '@/components/ui/VSkeleton/VSkeleton.vue'

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
  },

  skeleton: {
    type: Object,
    default: {
      variant: 'text',
      lines: 6
    }
  }
})

const emit = defineEmits(['menu'])

const linkName = computed(() => props.name || props.title)
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
}
</style>
