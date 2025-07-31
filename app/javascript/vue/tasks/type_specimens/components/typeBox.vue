<template>
  <div id="typeBox">
    <div class="panel separate-bottom">
      <div class="content header">
        <h3
          v-if="taxon.id"
          class="flex-separate middle"
        >
          <a
            :href="`/tasks/nomenclature/browse?taxon_name_id=${taxon.id}`"
            class="taxonname"
          >
            <span v-html="taxonNameAndAuthor" />
          </a>
          <div>
            <div class="horizontal-right-content margin-small-bottom gap-small">
              <OtuRadial
                ref="browseOtu"
                :object-id="taxon.id"
                :taxon-name="taxon.object_tag"
              />
              <RadialAnnotator :global-id="taxon.global_id" />
              <RadialObject :global-id="taxon.global_id" />
            </div>
            <div class="horizontal-right-content gap-small">
              <VPin
                type="TaxonName"
                :object-id="taxon.id"
              />
              <VBtn
                circle
                color="primary"
                :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxon.id}`"
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
          v-if="typeMaterial.id"
          v-html="typeMaterial.object_tag"
        />
      </div>
    </div>
    <div
      class="panel content"
      v-if="typesMaterial.length"
    >
      <button
        type="button"
        @click="newType"
        class="button normal-input button-default"
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
            v-for="item in typesMaterial"
            :key="item.id"
            :class="{ highlight: typeMaterial.id === item.id }"
          >
            <td>{{ item.type_type }} ({{ item.collection_object.total }})</td>
            <td>
              <div class="horizontal-right-content gap-xsmall">
                <RadialAnnotator :global-id="item.global_id" />
                <VBtn
                  circle
                  color="primary"
                  @click="setTypeMaterial(item)"
                >
                  <VIcon
                    name="pencil"
                    x-small
                  />
                </VBtn>
                <VBtn
                  circle
                  color="destroy"
                  @click="removeTypeSpecimen(item)"
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
import { GetterNames } from '../store/getters/getters'
import { computed } from 'vue'
import { useStore } from 'vuex'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import ActionNames from '../store/actions/actionNames'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import OtuRadial from '@/components/otu/otu.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const store = useStore()

const typeMaterial = computed(() => store.getters[GetterNames.GetTypeMaterial])
const typesMaterial = computed(
  () => store.getters[GetterNames.GetTypeMaterials]
)
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const taxonNameAndAuthor = computed(
  () => `${taxon.value.cached_html} ${taxon.value.cached_author_year || ''}`
)

function removeTypeSpecimen(item) {
  if (window.confirm('Are you sure you want to destroy this record?')) {
    store.dispatch(ActionNames.RemoveTypeSpecimen, item.id)
  }
}

function setTypeMaterial(material) {
  store.dispatch(ActionNames.LoadTypeMaterial, material)
}

function newType() {
  store.dispatch(ActionNames.SetNewTypeMaterial)
}
</script>
<style lang="scss" scoped>
.taxonname {
  font-size: 14px;
}
</style>
