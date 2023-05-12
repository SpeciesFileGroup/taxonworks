<template>
  <PanelContainer title="Biocurations">
    <ul class="no_bullets">
      <li
        v-for="({ groupName, items }) in biocurations"
        :key="groupName"
      >
        {{ groupName }}: <b>{{ items.map(item => item.object_tag).join(', ') }}</b>
      </li>
    </ul>
  </PanelContainer>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters.js'
import { useStore } from 'vuex'
import { computed } from 'vue'
import PanelContainer from './PanelContainer.vue'

const store = useStore()
const biocurations = computed(() => store.getters[GetterNames.GetBiocurations])

</script>
