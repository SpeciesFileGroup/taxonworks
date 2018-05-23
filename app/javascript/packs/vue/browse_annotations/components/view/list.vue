<template>
  <div>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Created by</th>
          <th>Created at</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in list">
          <td v-html="item.object_tag"/>
          <td v-html="item.created_by_id"/>
          <td v-html="item.created_at"/>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

export default {
  props: {
    list: {
      type: Array,
      required: true
    }
  }
}
</script>