<template>
  <div class="separate-top">
    <a
      v-for="(task, key) in metadata.tasks"
      :key="key"
      :href="task.path"
      class="panel content separate-left separate-bottom">
      {{ task.name }}
    </a>
  </div>
</template>
<script>

export default {
  props: {
    metadata: {
      type: Object,
      required: true
    }
  }
}
</script>
