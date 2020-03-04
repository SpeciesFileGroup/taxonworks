<template>
  <div class="panel content">
    <div class="flex-separate">
      <template v-if="(Array.isArray(records) && records.length) || Object.keys(records).length">
        <span><b>{{ value }}</b></span>
        <span>{{ Array.isArray(records) ? records.length : Object.keys(records).length }} records.</span>
      </template>
      <template v-else>
        <span>
          <b>{{ value }}</b>
        </span>
        <span>
          Unmatched
        </span>
      </template>
    </div>
    <ul v-if="records.length">
      <li v-for="record in records">
        <a
          :href="`/tasks/collection_objects/browse?collection_object_id=${record.id}`"
          v-html="record.object_tag"/>
      </li>
    </ul>
  </div>
</template>

<script>

export default {
  props: {
    value: {
      type: String,
      required: true
    },
    records: {
      type: [Object, Array],
      required: true
    }
  }
}
</script>