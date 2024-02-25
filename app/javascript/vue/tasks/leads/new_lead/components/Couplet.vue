<template>
  <div class="cplt_center">
    <VBtn
      :disabled="!store.lead.parent_id"
      color="primary"
      medium
      @click="store.loadKey(store.lead.parent_id)"
    >
      Go to the previous couplet
    </VBtn>

    <h2 class="title_and_annotator">
      <span v-html="'<i>At</i> ' + lead_tag(store.lead)" />
      <RadialAnnotator :global-id="store.lead.global_id" />
    </h2>
  </div>

  <div v-if="hasChildren">
    <div class="cplt_center">
      <label>Couplet number from citation: </label>
      <input
        v-model="store.lead.origin_label"
        type="text"
        class="normal-input"
        size="3"
      />
    </div>
    <div class="cplt_horizontal_buttons">
      <VBtn
        color="update"
        medium
        @click="updateCouplet"
      >
        Update (save)
      </VBtn>

      <VBtn
        v-if="allowDestroyCouplet"
        color="destroy"
        medium
        @click="destroyCouplet"
      >
        Delete both sides
      </VBtn>

      <VBtn
        v-else-if="allowDeleteCouplet"
        color="destroy"
        medium
        @click="deleteCouplet"
      >
        Delete both sides and reparent children from
        {{ store.left_has_children ? 'left' : 'right' }}
      </VBtn>

      <VBtn
        v-else
        color="destroy"
        disabled
        medium
      >
        Can't delete when both sides have children
      </VBtn>
    </div>

    <div class="left_and_right_cplt">
      <Lead
        side="left"
        :redirect-options="redirectOptions"
      />
      <Lead
        side="right"
        :redirect-options="redirectOptions"
      />
    </div>
  </div>

  <div v-else class="cplt_center">
    <p>No couplets below this one.</p>
    <VBtn
      color="update"
      medium
      @click="nextCouplet"
    >
      Create the next couplet
    </VBtn>
  </div>
</template>

<script setup>
import Lead from './Lead.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { computed, ref, watch } from 'vue'
import { lead_tag } from './display/formatters.js'
import { Lead as LeadEndpoint } from '@/routes/endpoints'
import { useStore } from '../store/useStore.js'

const store = useStore()

const hasChildren = computed(() => {
  return store.left && store.left.id && store.right && store.right.id
})

const allowDestroyCouplet = computed(() => {
  return (
    (!store.left_has_children && !store.right_has_children) &&
    store.lead.parent_id
  )
})

const allowDeleteCouplet = computed(() => {
  return (
    (!store.left_has_children && store.right_has_children) ||
    (!store.right_has_children && store.left_has_children)
  )
})

const redirectOptions = ref([])

function loadRedirectOptions() {
  LeadEndpoint.all_texts(store.lead.id).then(({ body }) => {
    const texts = body.all_texts.flatMap((o) => {
      if (
        (store.left && o.id == store.left.id) ||
        (store.right && o.id == store.right.id)
      ) {
        return []
      }
      let id_label = o.label ? ('[' + o.label + ']') : ''
      id_label = id_label + '[tw:' + o.id + ']'
      return [{
        id: o.id,
        text: id_label + ' ' + (o.text || '(No text)')
      }]
    })
    redirectOptions.value = texts
  })
}

watch(
  () => store.lead.id,
  () => loadRedirectOptions(),
  { immediate: true }
)

function updateCouplet() {
  const payload = {
      lead: store.lead,
      left: store.left,
      right: store.right
  }

  LeadEndpoint.update(store.lead.id, payload)
    .then(({ body }) => {
      // Future changes when redirect changes, so reload.
      store.loadKey(body)
      TW.workbench.alert.create('Couplet was successfully saved.', 'notice')
    })
    .catch(() => {})
}

function nextCouplet() {
  LeadEndpoint.create_for_edit(store.lead.id).then(({ body }) => {
    store.loadKey(body)
  })
}

function destroyCouplet() {
  if (window.confirm(
    'Delete both left and right sides?'
  )) {
    LeadEndpoint.destroy_couplet(store.lead.id)
      .then(() => {
        store.loadKey(store.lead.id)
        TW.workbench.alert.create('Couplet was successfully deleted.', 'notice')
      })
      .catch(() => {})
  }
}

function deleteCouplet() {
  if (window.confirm(
    'Delete both left and right sides and attach orphaned children to this parent?'
  )) {
    LeadEndpoint.delete_couplet(store.lead.id).then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Couplet was successfully deleted.', 'notice')
    })
  }
}
</script>

<style lang="scss" scoped>
.left_and_right_cplt {
  display: flex;
  justify-content:space-around;
}
.cplt_center {
  margin-top: 1em;
  margin-bottom: 1em;
  text-align: center;
}
.cplt_horizontal_buttons {
  display: grid;
  grid-template-columns: 50% 50%;
  column-gap: 0px;
  justify-items: start;
  margin-bottom: 2em;
  :first-child {
    justify-self: end;
    margin-right: 2em;
  }
  :last-child {
    margin-left: 2em;
  }
}
.title_and_annotator {
  span {
    display: inline-block;
  }
  div {
    display: inline-block;
    margin-left: .5em;
  }
}
</style>