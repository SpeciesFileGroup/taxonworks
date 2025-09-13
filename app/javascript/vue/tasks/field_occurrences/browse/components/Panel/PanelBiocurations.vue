<template>
  <PanelContainer title="Biocurations">
    <ul class="no_bullets">
      <li
        v-for="{ groupName, items } in store.biocurations"
        :key="groupName"
      >
        {{ groupName }}:
        <b>{{ items.map((item) => item.object_tag).join(', ') }}</b>
      </li>
    </ul>
  </PanelContainer>
</template>

<script setup>
import PanelContainer from './PanelContainer.vue'
import useBiocurationStore from '../../store/biocurations.js'

const store = useBiocurationStore()
</script>
