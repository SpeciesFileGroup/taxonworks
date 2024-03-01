<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <div class="cplt_center">
    <VBtn
      :disabled="!store.lead.parent_id"
      color="primary"
      medium
      @click="previousCouplet"
    >
      Go to the previous couplet
    </VBtn>

    <div class="title_and_annotator">
      <span
        class="large_type"
        v-html="'<b><i>At</i> ' + lead_tag(store.lead) + '</b>'"
      />
      <RadialAnnotator :global-id="store.lead.global_id" />
    </div>
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
        Update
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
        {{ leftHasChildren ? 'left' : 'right' }}
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
        :side-has-children="leftHasChildren"
        @editing-has-occurred="() => emit('editingHasOccurred')"
      />
      <Lead
        side="right"
        :redirect-options="redirectOptions"
        :side-has-children="rightHasChildren"
        @editing-has-occurred="() => emit('editingHasOccurred')"
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
import VSpinner from '@/components/ui/VSpinner.vue'
import { computed, ref, watch } from 'vue'
import { lead_tag } from '../../helpers/formatters.js'
import { Lead as LeadEndpoint } from '@/routes/endpoints'
import { useStore } from '../store/useStore.js'

const emit = defineEmits(['editingHasOccurred'])

const store = useStore()

const loading = ref(false)

const hasChildren = computed(() => {
  return store.left && !!store.left.id && store.right && !!store.right.id
})

const leftHasChildren = computed(() => {
  return store.left && !!store.left.id &&
    // Ignore redirect children.
    !store.left.redirect_id &&
    store.left_future.length > 0
})

const rightHasChildren = computed(() => {
  return store.right && !!store.right.id &&
    // Ignore redirect children.
    !store.right.redirect_id &&
    store.right_future.length > 0
})

const allowDestroyCouplet = computed(() => {
  return (
    (!leftHasChildren.value && !rightHasChildren.value) &&
    !!store.lead.parent_id
  )
})

const allowDeleteCouplet = computed(() => {
  return (
    (!leftHasChildren.value && rightHasChildren.value) ||
    (!rightHasChildren.value && leftHasChildren.value)
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

function previousCouplet() {
  store.loadKey(store.lead.parent_id)
  emit('editingHasOccurred')
}

function updateCouplet() {
  const payload = {
      lead: store.lead,
      left: store.left,
      right: store.right
  }

  loading.value = true
  LeadEndpoint.update(store.lead.id, payload)
    .then(({ body }) => {
      // Future changes when redirect changes, so reload.
      store.loadKey(body)
      TW.workbench.alert.create('Couplet was successfully saved.', 'notice')
      emit('editingHasOccurred')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function nextCouplet() {
  loading.value = true
  LeadEndpoint.create_for_edit(store.lead.id)
    .then(({ body }) => {
      store.loadKey(body)
      emit('editingHasOccurred')
    })
    .finally(() => {
      loading.value = false
    })
}

function destroyCouplet() {
  if (window.confirm(
    'Delete both left and right sides?'
  )) {
    loading.value = true
    LeadEndpoint.destroy_couplet(store.lead.id)
      .then(() => {
        store.loadKey(store.lead.id)
        TW.workbench.alert.create('Couplet was successfully deleted.', 'notice')
        emit('editingHasOccurred')
      })
      .catch(() => {})
      .finally(() => {
        loading.value = false
      })
  }
}

function deleteCouplet() {
  if (window.confirm(
    'Delete both left and right sides and attach orphaned children to this parent?'
  )) {
    loading.value = true
    LeadEndpoint.delete_couplet(store.lead.id)
      .then(() => {
        store.loadKey(store.lead.id)
        TW.workbench.alert.create('Couplet was successfully deleted.', 'notice')
        emit('editingHasOccurred')
      })
      .catch(() => {})
      .finally(() => {
        loading.value = false
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
  margin-top: 1em;
  span {
    display: inline-block;
  }
  // The radial annotator icon
  div {
    vertical-align: 6px;
    display: inline-block;
    margin-left: .5em;
  }
}
</style>