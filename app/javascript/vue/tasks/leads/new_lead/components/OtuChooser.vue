<template>
  <div class="field label-above">
    <label>OTU</label>
    <span
      class="middle"
      v-if="lead.otu_id"
    >
      <span
        v-html="otuTag"
        class="margin-small-right"
      />
      <span
        v-if="otuTag"
        @click="
          () => {
              otuTag = undefined
              lead.otu_id = null
          }
        "
        class="button button-circle btn-undo button-default"
      />
    </span>
    <OtuPicker
      v-else
      :clear-after="true"
      :input-id="lead.otu_id"
      @get-item="
        ($event) => {
          lead.otu_id = $event.id
          otuTag = $event.object_tag
        }
      "
    />
  </div>
</template>

<script setup>
import OtuPicker from '@/components/otu/otu_picker/otu_picker.vue'
import { Otu } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const props = defineProps({
  lead: {
    type: Object,
    required: true,
  }
})

const otuTag = ref()

function loadOtu() {
  if (props.lead.otu_id) {
    Otu.find(props.lead.otu_id).then(({ body }) => {
      otuTag.value = body.object_tag
    })
  }
}

watch(
  () => props.lead.id,
  () => loadOtu(),
  { immediate: true }
)
</script>