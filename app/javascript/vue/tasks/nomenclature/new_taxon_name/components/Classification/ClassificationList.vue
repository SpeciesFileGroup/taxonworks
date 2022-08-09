<template>
  <div>
    <switch-component
      class="margin-small-bottom"
      v-model="currentTab"
      :options="Object.values(TAB)"
    />

    <component
      :is="ListComponents[currentTab]"
      :lists="lists"
      :created="props.created"
      @close="currentTab = TAB.common"
      @select="emit('select', {
        name: $event.name,
        type: $event.type
      }); currentTab = TAB.common"
    />
  </div>
</template>

<script setup>
import { ref, defineAsyncComponent } from 'vue'
import SwitchComponent from 'components/switch'

const props = defineProps({
  created: {
    type: Array,
    default: () => []
  },

  lists: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])

const TAB = {
  common: 'Common',
  advanced: 'Advanced',
  showAll: 'Show all'
}

const ListComponents = {
  [TAB.common]: defineAsyncComponent({ loader: () => import('./ClassificationListCommon.vue') }),
  [TAB.advanced]: defineAsyncComponent({ loader: () => import('./ClassificationListAdvanced.vue') }),
  [TAB.showAll]: defineAsyncComponent({ loader: () => import('./ClassificationListAll.vue') })
}

const currentTab = ref(TAB.common)

</script>
