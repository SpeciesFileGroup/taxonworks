<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <div class="lead_and_lead_items">
    <BlockLayout class="lead">
      <template #header>
        <div class="full_width header-left-right">
          <div>
            <VBtn
              v-if="!positionIsFirst"
              color="update"
              circle
              @click="() => changeLeadPosition(DIRECTIONS['left'])"
              title="Move this lead left"
            >
              <VIcon
                x-small
                name="arrowLeft"
                title="Move this lead left"
              />
            </VBtn>

            <VBtn
              v-if="!positionIsLast"
              color="update"
              circle
              @click="() => changeLeadPosition(DIRECTIONS['right'])"
              title="Move this lead right"
            >
              <VIcon
                x-small
                name="arrowRight"
                title="Move this lead right"
              />
            </VBtn>

            <VBtn
              v-if="store.children.length > 2"
              color="destroy"
              circle
              @click="() => deleteSubTree()"
            >
              <VIcon
                x-small
                name="trash"
              />
            </VBtn>
          </div>
          <RadialAnnotator
            :global-id="store.children[position].global_id"
            @create="handleRadialCreate"
            @delete="handleRadialDelete"
            @update="handleRadialUpdate"
          />
        </div>
      </template>

      <template #body>
        <div
          v-if="!!store.last_saved.children[position].redirect_id"
          class="redirect_notice"
        >
          <i>This side is currently redirecting, to add leads below remove the redirection.</i>
        </div>
        <div class="lead_navigation">
          <VBtn
            :disabled="nextButtonDisabled"
            color="update"
            medium
            @click="nextCouplet()"
          >
            {{ editNextText }}
          </VBtn>

          <VBtn
            :disabled="!!store.last_saved.children[position].redirect_id || !leadHasChildren"
            color="create"
            medium
            @click="insertCouplet()"
          >
            Insert a couplet below
          </VBtn>
        </div>

        <div class="field label-above">
          <label>Text</label>
          <textarea
            class="full_width"
            rows="5"
            v-model="store.children[position].text"
          />
        </div>

        <OtuChooser :lead="store.children[position]"/>

        <div class="field label-above">
          <label>External link</label>
          <fieldset>
            <div class="field label-above">
              <label>URL (must include https:// or http://)</label>
              <textarea
                class="full_width"
                rows="2"
                v-model="store.children[position].link_out"
              />
            </div>
            <div class="field label-above">
              <label>URL text</label>
              <input
                type="text"
                class="normal-input full_width"
                v-model="store.children[position].link_out_text"
              />
            </div>
            <p v-if="displayLinkOut">
              Link: <a :href="store.children[position].link_out" target="_blank">
                {{ store.children[position].link_out_text }}
              </a>
            </p>
            <p v-else>
              Link: <i>(Requires both URL and text)</i>
            </p>
          </fieldset>
        </div>

        <div class="field label-above">
          <label>Redirect</label>
          <select
            class="redirect_select"
            v-model="store.children[position].redirect_id"
            :disabled="leadHasChildren"
          >
            <option :value="null"></option>
            <option
              v-for="option in redirectOptions"
              :key="option.id"
              :value="option.id"
              :selected="option.id == store.children[position].redirect_id"
            >
              {{ option.text }}
            </option>
          </select>
        </div>

        <Annotations
          :object_type="LEAD"
          :object_id="store.children[position].id"
          v-model:depiction="depictions"
        />

        <h3>Future couplets</h3>
        <FutureCoupletsList
          :future="store.futures[position]"
          :route-name="RouteNames.NewLead"
          :load-function="(id) => store.loadKey(id)"
        />
      </template>
    </BlockLayout>

    <LeadItems
      v-if="showLeadItems"
      @add-otu-index="(otuIndex) => addOtuIndex(otuIndex)"
      @lead-item-deleted="(otuId) => leadItemDeleted(otuId)"
      @otu-selected="(otuId) => addLeadItem(otuId)"
      :position="position"
      :lead-id="store.children[position].id"
      :show-add-otu="position == 0"
    />
  </div>
</template>

<script setup>
import { DEPICTION, LEAD } from '@/constants/index.js'
import { DIRECTIONS } from '../store/constants/directions.js'
import { computed, ref } from 'vue'
import { Lead as LeadEndpoint } from '@/routes/endpoints'
import { LeadItem } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { useAnnotationHandlers } from './composables/useAnnotationHandlers.js'
import { useInsertCouplet } from './composables/useInsertCouplet.js'
import { useStore } from '../store/useStore.js'
import { useUserOkayToLeave } from './composables/useUserOkayToLeave.js'
import Annotations from './Annotations.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FutureCoupletsList from '../../components/FutureCoupletsList.vue'
import LeadItems from './LeadItems.vue'
import OtuChooser from './OtuChooser.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  position: {
    type: Number,
    required: true
  },
  redirectOptions: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['editingHasOccurred'])

const store = useStore()

const depictions = ref([])
const loading = ref(false)

const leadHasChildren = computed(() => {
  return (!store.children[props.position].redirect_id &&
    store.futures[props.position].length > 0)
})

const nextButtonDisabled = computed(() => {
  return (
    !leadHasChildren.value &&
    !store.last_saved.children[props.position].redirect_id &&
    !store.last_saved.children[props.position].text
  )
})

const displayLinkOut = computed(() => {
  const linkOut = store.children[props.position].link_out
  return linkOut && store.children[props.position].link_out_text &&
    (linkOut.startsWith('https://') || linkOut.startsWith('http://'))
})

const editNextText = computed(() => {
  if (!!store.last_saved.children[props.position].redirect_id) {
    return 'Follow redirect and edit'
  } else if (leadHasChildren.value) {
    return 'Edit the next couplet'
  } else {
    if (store.last_saved.children[props.position].text) {
      return 'Create and edit the next couplet'
    } else {
      return 'Save text to enable creating the next couplet'
    }
  }
})

const positionIsFirst = computed(() => {
  return props.position == 0
})

const positionIsLast = computed(() => {
  return props.position == store.children.length - 1
})

const showLeadItems = computed(() => {
  return !!store.lead_item_otus.children[props.position] &&
    !store.lead_item_otus.children[props.position].fixed
})

const annotationLists = { [DEPICTION]: depictions }
const {
  handleRadialCreate,
  handleRadialDelete,
  handleRadialUpdate
} = useAnnotationHandlers(annotationLists)

function insertCouplet() {
  useInsertCouplet(store.children[props.position].id, loading, store, () => {
    store.loadKey(store.children[props.position].id)
      TW.workbench.alert.create(
        "Success - you're now editing the inserted couplet",
        'notice'
      )
      emit('editingHasOccurred')
  })
}


function addOtuIndex(otu_index) {
  store.addOtuIndex(props.position, otu_index)
}

function leadItemDeleted(otu_id) {
  if (!window.confirm('Are you sure you want to delete this otu row?')) {
    return
  }

  LeadItem.destroyItemInChildren({
    otu_id,
    parent_id: store.lead.id
  })
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Removed otu from lists.', 'notice')
    })
    .catch(() => {})
}

function addLeadItem(otu_id) {
  LeadItem.addLeadItemToChildLead({
    otu_id,
    parent_id: store.lead.id
  })
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Added otu to the last lead list.', 'notice')
    })
    .catch(() => {})
}

function nextCouplet() {
  if (!useUserOkayToLeave(store)) {
    return
  }
  if (leadHasChildren.value) {
    store.loadKey(store.children[props.position].id)
  } else if (!!store.last_saved.children[props.position].redirect_id) {
    store.loadKey(store.last_saved.children[props.position].redirect_id)
  } else {
    loading.value = true
    LeadEndpoint.add_children(
      store.children[props.position].id, { num_to_add: 2 }
    )
      .then(({ body }) => {
        store.loadKey(body)
      })
      .finally(() => {
        loading.value = false
      })
  }
  emit('editingHasOccurred')
}

function deleteSubTree() {
  const deleteWarningText = leadHasChildren.value
    ? 'Are you sure you want to delete this lead AND ALL LEADS BELOW IT?'
    : 'Are you sure you want to delete this lead?'

  if (!window.confirm(deleteWarningText)) {
    return
  }

  loading.value = true
  LeadEndpoint.destroy_subtree(store.children[props.position].id)
    .then(({ body }) => {
      const noticeText = (leadHasChildren.value
        ? 'Lead and descendants deleted.'
        : 'Lead deleted.')
      store.loadKey(body)
      TW.workbench.alert.create(noticeText, 'notice')
      emit('editingHasOccurred')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function changeLeadPosition(direction) {
  if (!useUserOkayToLeave(store,
    'You have unsaved data, are you sure you want to proceed?'
  )) {
    return
  }

  let childOrderList = [...Array(store.children.length).keys()]
  if (direction == DIRECTIONS.left) {
    childOrderList[props.position] = props.position - 1
    childOrderList[props.position - 1] = props.position
  }  else {
    childOrderList[props.position] = props.position + 1
    childOrderList[props.position + 1] = props.position
  }
  const payload = {
    reorder_list: childOrderList
  }

  loading.value = true
  LeadEndpoint.reorder_children(store.lead.id, payload)
    .then(({ body }) => {
      store.resetChildren(body.leads, body.futures, body.lead_item_otus)

      const direction_word = (direction == DIRECTIONS.left) ? 'left' : 'right'
      TW.workbench.alert.create('Moved lead ' + direction_word, 'notice')
      emit('editingHasOccurred')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

</script>

<style lang="scss" scoped>
.header-left-right {
  display: flex;
  > :first-child {
    flex-grow: 1;
  }
  > :first-child button {
    margin-right: 0.5em;
  }
}

.lead {
  display: flex;
  width: 100%;
}

.lead_and_lead_items {
  flex-grow: 1;
  min-width: 360px;
  max-width: 600px;
  display: flex;
  flex-direction: column;
}

.lead_navigation {
  display: flex;
  justify-content: space-evenly;
  gap: 3px;
}

.redirect_notice {
  margin-bottom: 1em;
}

.redirect_select[disabled] {
  opacity: .5;
}
</style>