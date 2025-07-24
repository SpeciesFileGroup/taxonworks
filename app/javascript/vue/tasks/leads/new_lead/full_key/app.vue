<template>
  <fieldset
    v-if="store.key_metadata"
    class="print-key"
    id="full_key"
  >
    <legend>Key preview</legend>
    <div
      v-for="parent in store.key_ordered_parents"
      :key="parent"
      :style="{marginLeft: (2 * store.key_metadata[parent].depth - 1) + 'em'}"
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
          <template v-if="parent == store.lead.id">
            <span
              :style="{position: 'relative', left: leftCalc(parent)}"
              class="gutter"
            >
              <b>>></b>
            </span>

            <span
              v-if="store.key_metadata[parent]['depth'] > 1"
              class="gutter"
            >
              <b>>></b>
            </span>
          </template>

          <template
            v-else
          >
            <template v-if="forwardLinkType(child) == 'lead_item_otus'">
              <span
                v-if="store.key_data[child]['lead_item_otus'].length > 1"
                :style="{position: 'relative', left: leftCalc(parent)}"
                class="gutter"
              >
                <b><span class="lead-item-mark">!!</span></b>
              </span>
              <span
                v-if="store.key_data[child]['lead_item_otus'].length == 1 && !store.key_data[child]['target_id']"
                :style="{position: 'relative', left: leftCalc(parent)}"
                class="gutter"
              >
                <b><span class="lead-item-one">!!</span></b>
              </span>
            </template>
          </template>

          <VBtn
            pill
            color="primary"
            @click.prevent="() => store.loadKey(parent)"
            class="key-button"
          >
            <span :id="`cplt-${begin(parent, child)}`">
              {{ begin(parent, child) }}
            </span>
          </VBtn>

          <template v-if="backLink(parent)">
            <a
              :href="`#cplt-${backLink(parent)}`"
              @click.prevent="scrollToCouplet(backLink(parent))"
            >
              {{ '&nbsp; (' + backLink(parent) + ').' }}
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
        {{ store.key_data[child]['text'] || '<no text>' }}
        <span
          v-if="store.key_data[child]['lead_item_otus']?.length > 1"
        >
          <b><span class="lead-item-mark">!!</span></b>
        </span>
        <span
          v-else-if="store.key_data[child]['lead_item_otus']?.length == 1 && !store.key_data[child]['target_id']"
        >
          <b><span class="lead-item-one">!!</span></b>
        </span>

        <!-- footer -->
        <template v-if="forwardLinkType(child) == 'otu'">
          ...&nbsp;
          <a
            :href="`${RouteNames.BrowseOtu}?otu_id=${store.key_data[child]['target_id']}`"
            target="_blank"
          >
            {{ store.key_data[child]['target_label'] }}
          </a>
        </template>

        <template v-else-if="forwardLinkType(child) == 'couplet'">
          ...&nbsp;
          <a
           :href="`#cplt-${store.key_data[child]['target_label']}`"
           @click.prevent="scrollToCouplet(store.key_metadata[child]['couplet_number'])"
          >
            {{ store.key_data[child]['target_label'] }}
          </a>
        </template>

        <template v-if="forwardLinkType(child) == 'lead_item_otus'">
          <template v-if="store.key_data[child]['target_id']">
            ...&nbsp;
            <a
              :href="`${RouteNames.BrowseOtu}?otu_id=${store.key_data[child]['target_id']}`"
              target="_blank"
            >
              {{ store.key_data[child]['target_label'] }}
            </a>
          </template>

          <ul class="key-ul">
            <li v-for="lio in store.key_data[child]['lead_item_otus']">
              {{ lio }}
            </li>
          </ul>
        </template>
      </div>
    </div>
  </fieldset>

</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { nextTick, onMounted, watch } from 'vue'
import useStore from '../store/leadStore'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()
let hasMounted = false
let scrollToOnMounted = null

function begin(parent, child) {
  if (store.key_data[child]['position'] == 0) {
    return store.key_metadata[parent]['couplet_number']
  } else {
    return '-----'
  }
}

function firstLine(child) {
  return store.key_data[child]['position'] == 0
}

function backLink(parent) {
  return store.key_data.back_couplets[store.key_metadata[parent]['couplet_number']]
}

function forwardLinkType(child) {
  if (!store.key_data[child]['target_label']) {
    if (store.key_data[child]['target_type'] == 'lead_item_otus') {
      return 'lead_item_otus'
    } else {
      return null
    }
  }

  // has target_label (writing this way to avoid the string '/api/v1/otus' for
  // otu)
  if (store.key_data[child]['target_type'] == 'internal') {
    return 'couplet'
  } else if (store.key_data[child]['target_type'] == 'lead_item_otus') {
    return 'lead_item_otus'
  } else {
    return 'otu'
  }
}

async function scrollToCouplet(couplet) {
  if (hasMounted) {
    await nextTick()
    const elt = document.getElementById(`cplt-${couplet}`)
    if (elt) {
      elt.scrollIntoView()
      const thisComponent = document.getElementById('full_key')
      thisComponent.scrollIntoView()
      thisComponent.scrollBy(0, -10)
      window.scrollBy(0, -10)
    }
  } else {
    scrollToOnMounted = couplet
  }
}

function leftCalc(parent) {
  return -(2 * store.key_metadata[parent].depth - 1) + 'em'
}

async function scrollToCurrentCouplet() {
  if (!store.key_metadata[store.lead.id]) {
    return
  }

  await nextTick()
  scrollToCouplet(
    store.key_metadata[store.lead.id]['couplet_number']
  )
}

watch(() => store.key_metadata, (new_metadata, old_metadata) => {
  if (!old_metadata && !!new_metadata) {
    scrollToCurrentCouplet()
  }
})

onMounted(() => {
  if (!!scrollToOnMounted) {
    scrollToCouplet(scrollToOnMounted)
  } else if (!!store.key_metadata) {
    scrollToCurrentCouplet()
  }
  hasMounted = true
})

</script>

<style scope>
.gutter {
  color: var(--color-update);
  width: 1.5em;
  margin-left: -1.5em;
  display: inline-block;
}

.lead-item-mark {
  color: var(--color-warning);
}

.lead-item-one {
  color: var(--color-data);
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
  padding-left: 3em;
  max-height: 400px;
  overflow-y: scroll;
  margin-bottom: 1.5em;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 4px 15px 0px;
}

.key-button {
  margin-top: 0.25em;
  margin-bottom: 0.25em;
}

.key-ul {
  margin-top: 0;
}
</style>