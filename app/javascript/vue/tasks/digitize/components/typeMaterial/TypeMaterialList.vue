<template>
  <table
    v-if="typeSpecimens.length"
    class="vue-table"
  >
    <thead>
      <tr>
        <th>Type material</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in typeSpecimens"
        :key="item.internalId"
      >
        <td class="full_width">
          <a
            v-if="item.id"
            :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${item.protonymId}`"
          >
            <span v-if="item.isUnsaved">{{ item.type }} of <span v-html="item.taxon.original_combination" /> (Changes unsaved)</span>
            <span
              v-else
              v-html="item.label"
            />
          </a>
          <span v-else>
            <span v-html="item.taxon.object_tag" />
            ({{ item.type }})
          </span>
        </td>
        <td>
          <div class="horizontal-right-content">
            <template v-if="item.id">
              <radial-annotator
                :global-id="item.globalId"
                type="annotations"
              />
              <VBtn
                class="margin-small-right"
                color="primary"
                circle
                @click="store.dispatch(ActionNames.SetTypeMaterial, item)"
              >
                <v-icon
                  x-small
                  name="pencil"
                  color="white"
                />
              </VBtn>
              <VBtn
                color="destroy"
                circle
                @click="warningMessage(() => store.dispatch(ActionNames.RemoveTypeMaterial, item))"
              >
                <v-icon
                  x-small
                  name="trash"
                  color="white"
                />
              </VBtn>
            </template>

            <template v-else>
              <VBtn
                class="margin-small-right"
                color="primary"
                circle
                @click="store.dispatch(ActionNames.SetTypeMaterial, item)"
              >
                <v-icon
                  x-small
                  name="pencil"
                  color="white"
                />
              </VBtn>
              <VBtn
                color="primary"
                circle
                @click="store.dispatch(ActionNames.RemoveTypeMaterial, item)"
              >
                <v-icon
                  x-small
                  name="trash"
                  color="white"
                />
              </VBtn>
            </template>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import RadialAnnotator from 'components/radials/annotator/annotator'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const store = useStore()
const typeSpecimens = computed(() => store.getters[GetterNames.GetTypeSpecimens])

function warningMessage (callback) {
  if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
    callback()
  }
}

</script>
