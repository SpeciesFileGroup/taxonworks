<template>
  <template v-if="store.key_metadata">
    <div
      v-for="parent in Object.keys(store.key_metadata)"
      :key="parent"
      >
      <div
        v-for="child in store.key_metadata[parent]['children']"
        :key="child"
      >
        <!--
          1. Child 1 text ... [next couplet # | otu]
          -- Child 2 text ... [next couplet # | otu]
        header  body                footer
        -->
        <!-- header-->
        <template v-if="firstLine(child)">
          <span :id="`cplt-${begin(parent, child)}`">
            {{ begin(parent, child) + (backLink(parent, child) ? '' : '.')}}
          </span>
          <template v-if="backLink(parent, child)">
            <a
              :href="`#cplt-${backLink(parent, child)}`"
              @click.prevent="scrollToCouplet(backLink(parent, child))"
            >
              {{ '(' + backLink(parent, child) + ').' }}
            </a>
          </template>
        </template>
        <template v-else>
          {{ begin(parent, child) }}
        </template>

        <!-- body -->
        {{ store.key_data[child]['text'] || 'blank' }}

        <!-- footer -->
        <template v-if="forwardLinkType(child) == 'otu'">
          <a
            :href="`${RouteNames.BrowseOtu}?otu_id=${store.key_data[child]['target_id']}`"
          >
            {{ store.key_data[child]['target_label'] }}
          </a>
        </template>
        <template v-else-if="forwardLinkType(child) == 'couplet'">
          <a
           :href="`#cplt-${store.key_data[child]['target_label']}`"
           @click.prevent="scrollToCouplet(child)"
          >
            {{ store.key_data[child]['target_label'] }}
          </a>
        </template>
        <template v-else>
          TBD
        </template>
      </div>
    </div>
  </template>

</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import useStore from '../store/leadStore'

const store = useStore()

function begin(parent, child) {
  if (store.key_data[child]['position'] == 0) {
    return store.key_metadata[parent]['couplet_number']
  } else {
    return '--'
  }
}

function firstLine(child) {
  return store.key_data[child]['position'] == 0
}

function backLink(parent, child) {
  return store.key_data.back_couplets[store.key_metadata[parent]['couplet_number']]
}

function forwardLinkType(child) {
  if (!store.key_data[child]['target_label']) return null

  if (store.key_data[child]['target_type'] == 'internal') {
    return 'couplet'
  } else {
    return 'otu'
  }
}

function scrollToCouplet(couplet) {
  const elt = document.getElementById(`cplt-${couplet}`)
  if (elt) elt.scrollIntoView()
}



</script>

<style scope>

</style>