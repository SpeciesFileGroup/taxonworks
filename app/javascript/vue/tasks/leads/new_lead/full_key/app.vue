<template>
  <fieldset
    v-if="store.key_metadata"
    class="print-key"
  >
    <legend>Key preview</legend>
    <div
      v-for="parent in Object.keys(store.key_metadata)"
      :key="parent"
      :style="{marginLeft: (2 * store.key_metadata[parent].depth - 2) + 'em'}"
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
          <span
            v-if="parent == store.lead.id"
            class="current"
          >
            <b>>></b>
          </span>
          <VBtn
            pill
            color="primary"
            @click.prevent="() => store.loadKey(parent)"
          >
            <span :id="`cplt-${begin(parent, child)}`">
              {{ begin(parent, child) }}
            </span>
          </VBtn>

          <template v-if="backLink(parent, child)">
            <a
              :href="`#cplt-${backLink(parent, child)}`"
              @click.prevent="scrollToCouplet(backLink(parent, child))"
            >
              {{ '&nbsp; (' + backLink(parent, child) + ').' }}
            </a>
          </template>
        </template>
        <template v-else>
          <a
            :href="`${RouteNames.NewLead}?lead_id=${parent}`"
            @click.prevent="() => store.loadKey(parent)"
          >
            {{ begin(parent, child) }}
          </a>
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
  </fieldset>

</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import useStore from '../store/leadStore'
import VBtn from '@/components/ui/VBtn/index.vue'

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
.current {
  color: var(--color-warning);
  width: 1.5em;
  margin-left: -1.5em;
  display: inline-block;
}

.print-key {
  width: fit-content;
  min-width: 600px;
  max-width: 80vw;
  margin: 0 auto;
  margin-top: 1.5em;
  border-top-left-radius: 0.9rem;
  border-bottom-left-radius: 0.9rem;
  padding: 1.5em;
  padding-left: 2em;
  max-height: 400px;
  overflow-y: scroll;
  margin-bottom: 1.5em;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 4px 15px 0px;
}
</style>