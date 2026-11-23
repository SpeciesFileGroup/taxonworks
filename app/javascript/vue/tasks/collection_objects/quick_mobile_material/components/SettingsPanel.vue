<template>
  <div class="horizontal-left-content align-start gap-medium">
    <fieldset class="fieldset">
      <legend>Repository</legend>
      <SmartSelectorItem
        v-if="store.repository"
        :item="store.repository"
        label="object_tag"
        @unset="store.setSetting('repository', null)"
      />
      <SmartSelector
        v-else
        model="repositories"
        klass="CollectionObject"
        target="CollectionObject"
        pin-section="Repositories"
        pin-type="Repository"
        @selected="(item) => store.setSetting('repository', item)"
      />
    </fieldset>

    <fieldset class="fieldset">
      <legend>Catalog number namespace</legend>
      <SmartSelectorItem
        v-if="store.namespace"
        :item="store.namespace"
        label="object_tag"
        @unset="store.setSetting('namespace', null)"
      />
      <SmartSelector
        v-else
        model="namespaces"
        klass="CollectionObject"
        pin-section="Namespaces"
        pin-type="Namespace"
        @selected="(item) => store.setSetting('namespace', item)"
      />
    </fieldset>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import useStore from '../store/store'

const store = useStore()
</script>
