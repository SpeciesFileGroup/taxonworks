<template>
  <div>
    <BlockLayout>
      <template #header>
        <div class="full_width flex-separate middle">
          <h3>Collection object</h3>
          <div class="horizontal-left-content middle gap-small">
            <a
              v-if="store.typeMaterial.collectionObject.id"
              target="blank"
              :href="`${RouteNames.DigitizeTask}?collection_object_id=${store.typeMaterial.collectionObject.id}&taxon_name_id=${store.taxonName?.id}`"
              >Expanded edit
            </a>
            <RadialAnnotator
              v-if="store.typeMaterial.id"
              :global-id="store.typeMaterial.collectionObject.globalId"
            />
            <RadialObject
              v-if="store.typeMaterial.id"
              :global-id="store.typeMaterial.collectionObject.globalId"
            />
          </div>
        </div>
      </template>
      <template #body>
        <VSpinner
          v-if="!store.typeMaterial.type"
          :show-spinner="false"
          legend="Select a type material"
        />
        <div class="switch-radio field">
          <VSwitch
            v-model="view"
            :options="tabOptions"
          />
        </div>
        <div class="flex-separate gap-medium">
          <FormCollectionObject
            v-show="view === TAB.new || view === TAB.edit"
          />

          <div
            v-if="view == 'existing'"
            class="field"
          >
            <label>Collection object</label>
            <autocomplete
              class="types_field"
              url="/collection_objects/autocomplete"
              param="term"
              label="label_html"
              placeholder="Search..."
              display="label"
              min="2"
              @getItem="setCO"
            />
          </div>
          <div class="flex-col gap-medium">
            <div class="field">
              <label>Depiction</label>
              <depictions-section />
              To add a catalog number use the radial annotator above after save.
            </div>
            <TaxonDetermination />
          </div>
        </div>
      </template>
    </BlockLayout>
    <div class="field margin-medium-top">
      <button
        :disabled="
          store.typeMaterial.collectionObject.total < 1 ||
          !store.typeMaterial.type
        "
        type="button"
        class="button normal-input button-submit"
        @click="() => store.save()"
      >
        {{ store.typeMaterial.id ? 'Update' : 'Create' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { watch, computed, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import FormCollectionObject from './FormCollectionObject.vue'
import DepictionsSection from './depictions/depictions.vue'
import TaxonDetermination from './TaxonDetermination.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import useStore from '../store/store.js'

const TAB = {
  edit: 'edit',
  new: 'new',
  existing: 'existing'
}

const store = useStore()

const tabOptions = computed(() =>
  store.typeMaterial.id ? [TAB.edit, TAB.existing] : [TAB.new, TAB.existing]
)

const view = ref(TAB.new)

watch(
  () => store.typeMaterial.id,
  (newVal) => {
    if (newVal) {
      view.value = TAB.edit
    }
  }
)

function setCO({ id }) {
  store.setCollectionObject(id)
  view.value = TAB.edit
}
</script>
