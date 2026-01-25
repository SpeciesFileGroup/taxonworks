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

          <VBtn
            :disabled="nextButtonDisabled || !leadItemsDivided"
            color="update"
            medium
            @click="() => nextCouplet()"
          >
            {{ editNextText }}
          </VBtn>

          <VBtn
            :disabled="!!store.last_saved.children[position].redirect_id || !leadHasChildren"
            color="create"
            medium
            @click="() => insertCouplet()"
          >
            Insert a couplet below
          </VBtn>

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

        <div class="field label-above">
          <label>Text</label>
          <textarea
            class="full_width"
            rows="5"
            v-model="store.children[position].text"
          />
        </div>

        <OtuChooser
          v-if="!showLeadItems"
          :lead="store.children[position]"
        />

        <div
          @click="() => { expandOptions = !expandOptions }"
          class="cursor-pointer inline"
        >
          <VBtn
            circle
            color="primary"
          >
            <VIcon
              x-small
              :name="expandOptions ? 'arrowDown' : 'arrowRight'"
            />
          </VBtn>
          <span class="margin-small-left">
            {{ expandOptions ? 'Fewer options' : 'More options' }}
          </span>
        </div>

        <div
          v-if="expandOptions"
          class="separate-top"
        >
          <OtuChooser
            v-if="!showLeadItems"
            :lead="store.children[position]"
          />
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
        </div>

        <Annotations
          :object_type="LEAD"
          :object_id="store.children[position].id"
          v-model:depiction="depictions"
        />

        <template v-if="store.layout == LAYOUTS.PreviousFuture">
          <h3>Future couplets</h3>
          <FutureCoupletsList
            :future="store.futures[position]"
            :route-name="RouteNames.NewLead"
            :load-function="(id) => store.loadKey(id)"
          />
        </template>
      </template>
    </BlockLayout>

    <LeadItems
      v-if="showLeadItems"
      :position="position"
      :lead-id="store.children[position].id"
      :show-add-otu="position == 0"
      :show-reset-otus="position == store.children.length - 1"
    />
  </div>
</template>

<script setup>
import { DEPICTION, LEAD } from '@/constants/index.js'
import { DIRECTIONS } from '../store/constants/directions.js'
import { computed, ref } from 'vue'
import { Lead as LeadEndpoint } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { useAnnotationHandlers } from './composables/useAnnotationHandlers.js'
import { useInsertCouplet } from './composables/useInsertCouplet.js'
import { useUserOkayToLeave } from './composables/useUserOkayToLeave.js'
import { LAYOUTS } from './layouts'
import { EXTEND } from './constants/index.js'
import Annotations from './Annotations.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FutureCoupletsList from '../../components/FutureCoupletsList.vue'
import LeadItems from './LeadItems.vue'
import OtuChooser from './OtuChooser.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useStore from '../store/leadStore.js'

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

const store = useStore()

const depictions = ref([])
const loading = ref(false)
const expandOptions = ref(false)

const leadHasChildren = computed(() => {
  return store.leadHasChildren(store.children[props.position], props.position)
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
      return 'Create the next couplet'
    } else {
      return 'Save text to proceed'
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

const leadItemsDivided = computed(() => {
  return store.expanded_lead_has_no_lead_items() ||
    store.lead_position_has_divided_lead_items(props.position)
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
  })
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
    const payload = {
      num_to_add: 2,
      extend: store.extend(EXTEND.All),
    }

    loading.value = true
    LeadEndpoint.add_children(
      store.children[props.position].id, payload
    )
      .then(({ body }) => {
        store.loadKey(body)
      })
      .finally(() => {
        loading.value = false
      })
  }
}

function deleteSubTree() {
  const deleteWarningText = leadHasChildren.value
    ? 'Are you sure you want to delete this lead AND ALL LEADS BELOW IT?'
    : 'Are you sure you want to delete this lead?'

  if (!window.confirm(deleteWarningText)) {
    return
  }

  const payload = {
    extend: store.extend(EXTEND.All)
  }

  loading.value = true
  LeadEndpoint.destroy_subtree(store.children[props.position].id, payload)
    .then(({ body }) => {
      const noticeText = (leadHasChildren.value
        ? 'Lead and descendants deleted.'
        : 'Lead deleted.')
      store.loadKey(body)
      TW.workbench.alert.create(noticeText, 'notice')
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
    reorder_list: childOrderList,
    extend: store.extend(EXTEND.CoupletAndFutures),
  }

  loading.value = true
  LeadEndpoint.reorder_children(store.lead.id, payload)
    .then(({ body }) => {
      store.resetChildren(body.leads, body.futures, body.lead_item_otus)
      store.update_from_extended(EXTEND.CoupletAndFutures, body)

      const direction_word = (direction == DIRECTIONS.left) ? 'left' : 'right'
      TW.workbench.alert.create('Moved lead ' + direction_word, 'notice')
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
  > :first-child button {
    margin-right: 0.5em;
  }
  justify-content: space-between;
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

.redirect_notice {
  margin-bottom: 1em;
}

.redirect_select[disabled] {
  opacity: .5;
}

.inline .expand-box {
	width: 24px;
	height: 24px;
	padding: 0px;
	background-size: 10px;
	background-position: center;
}
</style>