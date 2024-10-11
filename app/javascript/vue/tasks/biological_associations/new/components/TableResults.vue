<template>
  <div class="full_width">
    <table class="table-striped full_width">
      <thead>
        <tr>
          <th>Subject</th>
          <th>Relationship</th>
          <th>Object</th>
          <th>Citation</th>
          <th class="w-2" />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
          @click="() => emit('select', item)"
        >
          <td v-html="item.subject.object_tag" />
          <td v-html="item.relationship.object_tag" />
          <td v-html="item.object.object_tag" />
          <td v-html="item.citation.object_label" />
          <td>
            <div>
              <VBtn
                circle
                color="primary"
              >
                <VIcon
                  x-small
                  name="pencil"
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select'])
</script>
