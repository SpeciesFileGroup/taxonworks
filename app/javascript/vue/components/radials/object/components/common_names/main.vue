<template>
  <div class="common_name_annotator separate-bottom">
    <div class="separate-bottom">
      <label>Name</label>
      <input
        type="text"
        placeholder="Name"
        v-model="commonName.name"
      />
    </div>

    <fieldset>
      <legend>Geographic area</legend>
      <SmartSelector
        model="geographic_areas"
        klass="CollectingEvent"
        target="CollectingEvent"
        pin-section="GeographicAreas"
        label="name"
        :add-tabs="['map']"
        pin-type="GeographicArea"
        @selected="(item) => (geographicArea = item)"
      >
        <template #map>
          <GeographicAreaMapPicker
            @select="(item) => (geographicArea = item)"
          />
        </template>
      </SmartSelector>
      <div>
        <SmartSelectorItem
          :item="geographicArea"
          label="name"
          @unset="() => (geographicArea = null)"
        />
      </div>
    </fieldset>

    <fieldset>
      <legend>Language</legend>
      <SmartSelector
        model="languages"
        klass="AlternateValue"
        pin-section="Languages"
        pin-type="Language"
        label="english_name"
        @selected="(item) => (language = item)"
      />
      <SmartSelectorItem
        :item="language"
        label="english_name"
        @unset="() => (language = null)"
      />
    </fieldset>

    <div class="field margin-medium-top">
      <label>Start year</label>
      <input
        class="date-input"
        type="number"
        placeholder="Start year"
        v-model="commonName.start_year"
        min="1600"
        max="3000"
      />
    </div>

    <div class="field">
      <label>End year</label>
      <input
        class="date-input"
        type="number"
        placeholder="End year"
        v-model="commonName.end_year"
        min="1600"
        max="3000"
      />
    </div>

    <div class="margin-medium-bottom">
      <VBtn
        color="create"
        medium
        :disabled="!validate"
        @click="saveCommonName"
      >
        {{ commonName.id ? 'Update' : 'Create' }}
      </VBtn>
      <VBtn
        class="margin-small-left"
        medium
        color="primary"
        @click="reset"
        type="button"
      >
        New
      </VBtn>
    </div>

    <TableList
      class="list"
      label="object_tag"
      :header="['Name', 'Geographic area', 'Language', 'Start', 'End', '']"
      :attributes="[
        'name',
        ['geographic_area', 'object_tag'],
        'language_tag',
        'start_year',
        'end_year'
      ]"
      :list="list"
      edit
      @edit="setCommonName"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import TableList from '@/components/table_list.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import makeCommonName from '@/factory/CommonName.js'
import GeographicAreaMapPicker from '@/components/ui/SmartSelector/GeographicAreaMapPicker.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { CommonName } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { useSlice } from '@/components/radials/composables'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const validate = computed(
  () => commonName.value.name.length > 2 && commonName.value.otu_id
)

const commonName = ref(makeCommonName(props.objectId))
const geographicArea = ref(null)
const language = ref(null)

function reset() {
  commonName.value = makeCommonName(props.objectId)
  geographicArea.value = null
  language.value = null
}

function saveCommonName() {
  const payload = {
    common_name: {
      ...commonName.value,
      geographic_area_id: geographicArea.value?.id || null,
      language_id: language.value?.id || null
    }
  }

  const saveRequest = commonName.value.id
    ? CommonName.update(commonName.value.id, payload)
    : CommonName.create(payload)

  saveRequest.then(({ body }) => {
    addToList(body)
    reset()
  })
}

function setCommonName(item) {
  commonName.value = { ...item }

  geographicArea.value = item.geographic_area_id
    ? {
        id: item.geographic_area_id,
        name: item.geographic_area?.object_tag
      }
    : null

  language.value = item.language_id
    ? {
        id: item.language_id,
        english_name: item.language_tag
      }
    : null
}

function removeItem(item) {
  CommonName.destroy(item.id).then(() => {
    removeFromList(item)
  })
}

CommonName.where({ otu_id: props.objectId }).then(({ body }) => {
  list.value = body
})
</script>

<style lang="scss">
.radial-annotator {
  .common_name_annotator {
    label {
      display: block;
    }
    .date-input {
      min-width: 150px;
    }
    .vue-autocomplete-input {
      width: 374px;
    }
  }
}
</style>
