<template>
  <div class="full_width">
    <fieldset>
      <legend>Asserted environments</legend>

      <template v-if="collectingEvent.id">
        <AutoselectField
          url="/asserted_environments/autoselect"
          param="uri"
          placeholder="Search ENVO, or terms already used in this project"
          reset-on-select
          @select="addFromSelection"
        />
      </template>
      <span
        v-else
        class="subtle"
      >
        Save the collecting event first to add environments.
      </span>

      <DisplayList
        v-if="list.length"
        class="margin-medium-top"
        :list="list"
        label="uri_label"
        @delete="removeItem"
      />
    </fieldset>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { AssertedEnvironment } from '@/routes/endpoints'
import { COLLECTING_EVENT } from '@/constants'
import DisplayList from '@/components/displayList.vue'
import AutoselectField from '@/components/ui/AutoselectField.vue'

const collectingEvent = defineModel({
  type: Object,
  required: true
})

const list = ref([])

function load() {
  if (!collectingEvent.value.id) {
    list.value = []
    return
  }

  AssertedEnvironment.where({
    asserted_environment_object_id: collectingEvent.value.id,
    asserted_environment_object_type: COLLECTING_EVENT
  }).then(({ body }) => {
    list.value = body
  })
}

function addFromSelection(item) {
  AssertedEnvironment.create({
    asserted_environment: {
      asserted_environment_object_id: collectingEvent.value.id,
      asserted_environment_object_type: COLLECTING_EVENT,
      uri: item.response_values.uri,
      uri_label: item.response_values.uri_label
    }
  }).then(({ body }) => {
    list.value.push(body)
  })
}

function removeItem(item) {
  AssertedEnvironment.destroy(item.id).then(() => {
    list.value = list.value.filter((existing) => existing.id !== item.id)
  })
}

watch(() => collectingEvent.value.id, load, { immediate: true })
</script>
