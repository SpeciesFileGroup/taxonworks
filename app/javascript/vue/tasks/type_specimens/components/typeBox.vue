<template>
  <div id="typeBox">
    <div class="panel separate-bottom">
      <div class="content header">
        <h3
          v-if="store.taxonName?.id"
          class="flex-separate middle"
        >
          <a
            :href="`${RouteNames.BrowseNomenclature}?taxon_name_id=${store.taxonName.id}`"
            class="taxonname"
          >
            <span v-html="taxonNameAndAuthor" />
          </a>
          <div>
            <div
              class="horizontal-right-content margin-small-bottom gap-xsmall"
            >
              <OtuRadial
                ref="browseOtu"
                :object-id="store.taxonName.id"
                :taxon-name="store.taxonName.object_tag"
              />
              <RadialAnnotator :global-id="store.taxonName.global_id" />
              <RadialObject :global-id="store.taxonName.global_id" />
            </div>
            <div class="horizontal-right-content gap-xsmall">
              <VBtn
                circle
                color="primary"
                title="Change taxon name"
                @click="reset"
              >
                <VIcon
                  title="Change taxon name"
                  name="undo"
                  x-small
                />
              </VBtn>
              <VPin
                type="TaxonName"
                :object-id="store.taxonName.id"
              />
              <VBtn
                circle
                color="primary"
                :href="`${RouteNames.NewTaxonName}?taxon_name_id=${store.taxonName.id}`"
              >
                <VIcon
                  x-small
                  name="pencil"
                />
              </VBtn>
            </div>
          </div>
        </h3>
        <span
          v-if="store.typeMaterial.id"
          v-html="store.typeMaterial.label"
        />
      </div>
    </div>
    <div
      class="panel content"
      v-if="store.typeMaterials.length"
    >
      <button
        type="button"
        class="button normal-input button-default"
        @click="() => store.setNewTypeMaterial()"
      >
        New type
      </button>

      <table class="margin-medium-top full_width">
        <thead>
          <tr>
            <th>Type</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in store.typeMaterials"
            :key="item.id"
            :class="{ highlight: store.typeMaterial.id === item.id }"
          >
            <td>{{ item.type }} ({{ item.collectionObject.total }})</td>
            <td>
              <div class="horizontal-right-content gap-xsmall">
                <RadialAnnotator :global-id="item.globalId" />
                <VBtn
                  circle
                  color="primary"
                  @click="() => store.setTypeMaterial(item)"
                >
                  <VIcon
                    name="pencil"
                    x-small
                  />
                </VBtn>
                <VBtn
                  circle
                  color="destroy"
                  @click="() => removeTypeMaterial(item)"
                >
                  <VIcon
                    name="trash"
                    x-small
                  />
                </VBtn>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import useStore from '../store/store.js'
import useDepictionStore from '../store/depictions.js'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'
import useSoftvalidationStore from '@/components/Form/FormCollectingEvent/store/softValidations'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import OtuRadial from '@/components/otu/otu.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const store = useStore()
const depictionStore = useDepictionStore()
const biocurationStore = useBiocurationStore()
const validationStore = useSoftvalidationStore()

const taxonNameAndAuthor = computed(() =>
  [store.taxonName.cached_html, store.taxonName.cached_author_year]
    .filter(Boolean)
    .join(' ')
)

function reset() {
  store.$reset()
  depictionStore.$reset()
  biocurationStore.$reset()
  validationStore.$reset()
}

function removeTypeMaterial(item) {
  if (
    window.confirm(
      `You're trying to delete this record. Are you sure want to proceed?`
    )
  ) {
    store.remove(item)
  }
}
</script>
<style lang="scss" scoped>
.taxonname {
  font-size: 14px;
}
</style>
