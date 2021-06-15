<template>
  <div class="panel content">
    <div class="flex-separate">
      <template v-if="records.length">
        <span><b>{{ name }}</b></span>
        <span>{{ records.length }} records.</span>
      </template>
      <template v-else>
        <a :href="`/tasks/nomenclature/new_taxon_name?name=${name}`">
          <b>{{ name }}</b>
        </a>
        <span>
          Unmatched
        </span>
      </template>
    </div>
    <ul v-if="records.length">
      <li
        v-for="record in records"
        :key="record.id">
        <a
          :href="`/tasks/nomenclature/browse?taxon_name_id=${record.id}`"
          v-html="record.object_tag"/>
      </li>
    </ul>
  </div>
</template>

<script>

export default {
  props: {
    name: {
      type: String,
      required: true
    },

    records: {
      type: Array,
      required: true
    }
  }
}
</script>
