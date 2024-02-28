<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <BlockLayout class="lead">
    <template #header>
      <div class="flex-separate middle full_width">
        <h3 v-html="lead_id(store[side])" />
        <div class="horizontal-right-content gap-small header-radials">
          <RadialAnnotator
            :global-id="store[side].global_id"
            @create="handleRadialCreate"
            @delete="handleRadialDelete"
            @update="handleRadialUpdate"
          />
        </div>
      </div>
    </template>

    <template #body>
      <div
        v-if="store[side + '_had_redirect_on_save']"
        class="redirect_notice"
        v-html="'<i>This side is currently redirecting, to add couplets below remove the redirection.</i>'"
      />
      <div class="navigation">
        <VBtn
          color="update"
          medium
          @click="nextCouplet()"
        >
          {{ editNextText }}
        </VBtn>

        <VBtn
          :disabled="store[side + '_had_redirect_on_save'] || !sideHasChildren"
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
          v-model="store[side].text"
        />
      </div>

      <OtuChooser :lead="store[side]"/>

      <div class="field label-above">
        <label>External link</label>
        <fieldset>
          <div class="field label-above">
            <label>URL (don't include http://)</label>
            <textarea
              class="full_width"
              rows="2"
              v-model="store[side].link_out"
            />
          </div>
          <div class="field label-above">
            <label>URL text</label>
            <input
              type="text"
              class="normal-input full_width"
              v-model="store[side].link_out_text"
            />
          </div>
          <p v-if="displayLinkOut">
            Link: <a :href="'http://' + store[side].link_out" target="_blank">
              {{ store[side].link_out_text }}
            </a>
          </p>
          <p v-else>
            Link: <span v-html="'<i>(Requires both URL and text)</i>'" />
          </p>
        </fieldset>
      </div>

      <div class="field label-above">
        <label>Redirect</label>
        <select
          class="redirect_select"
          v-model="store[side].redirect_id"
          :disabled="sideHasChildren"
        >
          <option :value="null"></option>
          <option
            v-for="option in redirectOptions"
            :key="option.id"
            :value="option.id"
            :selected="option.id == store[side].redirect_id"
          >
            {{ option.text }}
          </option>
        </select>
      </div>

      <Annotations
        :object_type="LEAD"
        :object_id="store[side].id"
        v-model:depiction="depictions"
      />

      <h3>Future Couplets</h3>
      <FutureCouplets :side="side" />
    </template>
  </BlockLayout>
</template>

<script setup>
import { lead_id } from '../../helpers/formatters.js'
import { DEPICTION, LEAD } from '@/constants/index.js'
import { Lead } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { useAnnotationHandlers } from './composables/useAnnotationHandlers.js'
import { useStore } from '../store/useStore.js'
import Annotations from './Annotations.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FutureCouplets from './FutureCouplets.vue'
import OtuChooser from './OtuChooser.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/spinner'

const props = defineProps({
  side: {
    type: String,
    required: true,
    validator(value) {
      return ['left', 'right'].includes(value)
    }
  },
  sideHasChildren: {
    type: Boolean,
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

const displayLinkOut = computed(() => {
  return store[props.side].link_out && store[props.side].link_out_text
})

const editNextText = computed(() => {
  if (store[props.side].redirect_id) {
    return 'Follow redirect and edit'
  } else {
    return props.sideHasChildren ?
      'Edit the next couplet' :
      'Create and edit the next couplet'
  }
})

const annotationLists = { [DEPICTION]: depictions }
const {
  handleRadialCreate,
  handleRadialDelete,
  handleRadialUpdate
} = useAnnotationHandlers(annotationLists)

function insertCouplet() {
  if (window.confirm(
    'Insert a couplet below this one? Any existing children will be reparented.'
  )) {
    loading.value = true
    Lead.insert_couplet(store[props.side].id)
      .then(() => {
        store.loadKey(store[props.side].id)
        TW.workbench.alert.create(
          "Success - you're now editing the inserted couplet",
          'notice'
        )
      })
      .finally(() => {
        loading.value = false
      })
  }
}

function nextCouplet() {
  if (props.sideHasChildren) {
    store.loadKey(store[props.side].id)
  } else if (store[props.side].redirect_id) {
    store.loadKey(store[props.side].redirect_id)
  } else {
    loading.value = true
    Lead.create_for_edit(store[props.side].id)
      .then(({ body }) => {
        store.loadKey(body)
      })
      .finally(() => {
        loading.value = false
      })
  }
}
</script>

<style lang="scss" scoped>
.lead {
  max-width: 600px;
  flex-grow: 1;
  margin-bottom: 2em;
}
.navigation {
  display: flex;
  justify-content: space-evenly;
}
.redirect_notice {
  margin-bottom: 1em;
}
.redirect_select[disabled] {
  opacity: .5;
}
</style>