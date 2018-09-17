<template>
  <div class="descriptor-details">
    <p>{{ descriptor.description }}</p>
    <notes
    :notes="descriptor.notes"/>
    <depictions
    :depictions="descriptor.depictions"/>
  </div>
</template>

<script>
import notes from '../Notes/Notes.vue'
import depictions from '../Depictions/Depictions.vue'

export default {
  name: 'DescriptorDetails',
  props: ['descriptor'],
  components: {
    notes,
    depictions
  }
}
</script>
