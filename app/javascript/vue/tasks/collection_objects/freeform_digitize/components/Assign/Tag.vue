<template>
  <fieldset>
    <legend>Tag</legend>
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Keyword' }"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="CollectionObject"
      target="CollectionObject"
      pin-section="Keywords"
      pin-type="Keyword"
      @selected="store.addTag"
    >
      <template #tabs-right>
        <VLock
          class="margin-small-left"
          v-model="lock.tags"
        />
      </template>
    </SmartSelector>

    <ListComponent
      v-if="store.tags.length"
      :list="store.tags"
      @delete-index="store.removeTag"
      label="label"
    />
  </fieldset>
</template>

<script setup>
import useLockStore from '../../store/lock.js'
import useStore from '../../store/tags.js'
import SmartSelector from '@/components/ui/SmartSelector'
import ListComponent from '@/components/displayList'
import VLock from '@/components/ui/VLock/index.vue'

const lock = useLockStore()
const store = useStore()
</script>
