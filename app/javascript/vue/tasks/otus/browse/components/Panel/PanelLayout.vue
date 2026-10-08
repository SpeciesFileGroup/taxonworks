<template>
  <BlockLayout
    v-if="!isHidden"
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
        color="transparent"
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
import { computed, onUnmounted, watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VSkeleton from '@/components/ui/VSkeleton/VSkeleton.vue'
import { useSettingsStore } from '../../store'

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
  },

  empty: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['menu'])

const settingStore = useSettingsStore()

const linkName = computed(() => props.name || props.title)

const isEmpty = computed(() => !props.spinner && props.empty)

const isHidden = computed(() => isEmpty.value && settingStore.hideEmptyPanels)

watch(
  [isEmpty, linkName],
  ([value, name], previous) => {
    const previousName = previous?.[1]

    if (previousName && previousName !== name) {
      settingStore.unregisterPanel(previousName)
    }

    settingStore.setPanelIsEmpty(name, value)
  },
  { immediate: true }
)

onUnmounted(() => settingStore.unregisterPanel(linkName.value))
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
