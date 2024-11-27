<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

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
            />
          </VBtn>

          <VBtn
            v-if="store.children.length > 2 && !leadHasChildren"
            color="destroy"
            circle
            @click="() => deleteLead()"
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
        <i>This side is currently redirecting, to add options below remove the redirection.</i>
      </div>
      <div class="navigation">
        <VBtn
          :disabled="nextButtonDisabled"
          color="update"
          medium
          @click="nextOptions()"
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

      <h3>Future Option Sets</h3>
      <FutureOptionSetsList
        :future="store.futures[position]"
        :route-name="RouteNames.NewLead"
        :load-function="(id) => store.loadKey(id)"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { DEPICTION, LEAD } from '@/constants/index.js'
import { DIRECTIONS } from '../store/constants/directions.js'
import { computed, ref } from 'vue'
import { Lead as LeadEndpoint } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { useAnnotationHandlers } from './composables/useAnnotationHandlers.js'
import { useStore } from '../store/useStore.js'
import Annotations from './Annotations.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FutureOptionSetsList from '../../components/FutureOptionSetsList.vue'
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
  // TODO: this can be computed using position, do that
  leadHasChildren: {
    type: Boolean,
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

const nextButtonDisabled = computed(() => {
  return (
    !props.leadHasChildren &&
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
  } else if (props.leadHasChildren) {
    return 'Edit the next option set'
  } else {
    if (store.last_saved.children[props.position].text) {
      return 'Create and edit the next option set'
    } else {
      return 'Save text to enable creating the next option set'
    }
  }
})

const positionIsFirst = computed(() => {
  return props.position == 0
})

const positionIsLast = computed(() => {
  return props.position == store.children.length - 1
})

const annotationLists = { [DEPICTION]: depictions }
const {
  handleRadialCreate,
  handleRadialDelete,
  handleRadialUpdate
} = useAnnotationHandlers(annotationLists)

function insertCouplet() {
  if (!userOkayToLeave() ||
    !window.confirm(
      'Insert a couplet below this one? Any existing children will be reparented.'
    )
  ) {
    return
  }
  loading.value = true
  LeadEndpoint.insert_couplet(store.children[props.position].id)
    .then(() => {
      store.loadKey(store.children[props.position].id)
      TW.workbench.alert.create(
        "Success - you're now editing the inserted couplet",
        'notice'
      )
      emit('editingHasOccurred')
    })
    .finally(() => {
      loading.value = false
    })
}

function nextOptions() {
  if (!userOkayToLeave()) {
    return
  }
  if (props.leadHasChildren) {
    store.loadKey(store.children[props.position].id)
  } else if (!!store.last_saved.children[props.position].redirect_id) {
    store.loadKey(store.last_saved.children[props.position].redirect_id)
  } else {
    loading.value = true
    LeadEndpoint.create_for_edit(store.children[props.position].id)
      .then(({ body }) => {
        store.loadKey(body)
      })
      .finally(() => {
        loading.value = false
      })
  }
  emit('editingHasOccurred')
}

function userOkayToLeave() {
  if (store.dataChangedSinceLastSave() &&
    !window.confirm(
      'You have unsaved data, are you sure you want to navigate to a new option set?'
    )
  ) {
    return false
  }
  return true
}

function deleteLead() {
  if (!window.confirm('Are you sure you want to delete this lead?')) {
    return
  }

  loading.value = true
  LeadEndpoint.destroy_leaf(store.children[props.position].id)
    .then(() => {
      store.deleteChild(props.posittion)
      TW.workbench.alert.create('Lead deleted', 'notice')
      emit('editingHasOccurred')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function changeLeadPosition(direction) {
  const payload = {
    direction
  }

  loading.value = true
  LeadEndpoint.swap(store.children[props.position].id, payload)
    .then(({ body }) => {
      store.swapLeads(body)

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
  max-width: 600px;
  min-width: 360px;
  flex-grow: 1;
  margin-bottom: 2em;
}
.navigation {
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