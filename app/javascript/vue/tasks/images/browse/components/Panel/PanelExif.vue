<template>
  <div
    v-if="metadata"
    class="panel content"
  >
    <h3>Metadata</h3>
    <table class="table-striped">
      <thead>
        <tr>
          <th>Attribute</th>
          <th>Value</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(value, attr) in metadata"
          :key="attr"
        >
          <td>{{ attr }}</td>
          <td>{{ value }}</td>
        </tr>
      </tbody>
    </table>
    <
  </div>
</template>

<script setup>
import EXIF from 'exifr'
import { ref, watch, onMounted } from 'vue'

const props = defineProps({
  imageUrl: {
    type: String
  }
})

const metadata = ref()

onMounted(async () => {
  const data = await EXIF.parse(props.imageUrl)

  metadata.value = data
})
</script>
