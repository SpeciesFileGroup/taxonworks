<template>
  <PanelContainer title="Identifiers">
    <ul class="no_bullets">
      <li
        v-for="identifier in identifiers"
        :key="identifier.id"
        v-html="identifier.objectTag"
      />
    </ul>
  </PanelContainer>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'

const props = defineProps({
  type: {
    type: String,
    required: true
  }
})

const store = useStore()
const identifiers = computed(() => store.getters[GetterNames.GetIdentifiersFor](props.type))
</script>
