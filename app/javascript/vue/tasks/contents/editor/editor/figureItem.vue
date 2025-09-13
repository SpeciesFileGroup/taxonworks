<template>
  <div class="card-handle panel-figure panel content">
    <div
      class="figure-header horizontal-center-content middle margin-medium-bottom"
    >
      <img :src="depiction.image.image_file_url" />
    </div>
    <div class="figures-body">
      <div class="field">
        <label class="d-block">Figure label</label>
        <input
          class="horizontal-center-content middle full_width"
          type="text"
          v-model="depiction.figure_label"
        />
      </div>

      <div class="field">
        <label class="d-block">Caption</label>
        <textarea
          class="full_width"
          rows="4"
          v-model="depiction.caption"
        />
      </div>
      <div class="flex-separate">
        <VBtn
          medium
          color="update"
          @click="update()"
        >
          Update
        </VBtn>
        <div class="horizontal-left-content gap-small">
          <VBtn
            circle
            medium
            color="primary"
            title="Add depiction link to the content"
            @click="setDepictionLink()"
          >
            <VIcon
              small
              color="white"
              name="link"
            />
          </VBtn>

          <VBtn
            circle
            medium
            color="destroy"
            @click="deleteDepiction()"
          >
            <VIcon
              x-small
              color="white"
              name="trash"
            />
          </VBtn>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onBeforeMount, watch } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { removeFromArray } from '@/helpers'
import useContentStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  figure: {
    type: Object,
    required: true
  }
})

const store = useContentStore()
const depiction = ref()

onBeforeMount(() => {
  depiction.value = props.figure
})

watch(
  () => props.figure,
  (newVal) => {
    depiction.value = newVal
  }
)

function deleteDepiction() {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    Depiction.destroy(depiction.value.id).then(() => {
      removeFromArray(store.depictions, depiction.value)
      TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
    })
  }
}

function update() {
  const payload = {
    depiction: {
      caption: depiction.value.caption,
      figure_label: depiction.value.figure_label
    }
  }

  Depiction.update(depiction.value.id, payload).then(() => {
    TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
  })
}

function setDepictionLink() {
  const text = `Fig. ${depiction.value.figure_label || 'X'}`

  store.content.text += `[${text}](/depictions/${depiction.value.id})`
}
</script>

<style scoped>
.panel-figure {
  width: 270px;
  min-height: 300px;
}

.figure-header {
  border: 1px solid black;
  height: 300px;
  max-height: 300px;

  img {
    max-width: 100%;
    max-height: 100%;
  }
}
</style>
