<template>
  <PanelContainer title="Buffered">
    <hr>
    <PanelBufferedSection
      class="margin-small-bottom"
      v-if="collectionObject.bufferedCollectingEvent"
      title="Collecting event"
      :text="collectionObject.bufferedCollectingEvent"
    />
    <PanelBufferedSection
      v-if="collectionObject.bufferedDeterminations"
      class="margin-small-bottom"
      title="Determinations"
      :text="collectionObject.bufferedDeterminations"
    />
    <PanelBufferedSection
      v-if="collectionObject.bufferedLabels"
      class="margin-small-bottom"
      title="Other labels"
      :text="collectionObject.bufferedLabels"
    />
  </PanelContainer>
</template>

<script setup>
import { GetterNames } from '../../../store/getters/getters'
import { computed } from 'vue'
import { useStore } from 'vuex'
import PanelBufferedSection from './PanelBufferedSection.vue'
import PanelContainer from '../PanelContainer.vue'

const store = useStore()

const collectionObject = computed(() => store.getters[GetterNames.GetCollectionObject])
</script>
