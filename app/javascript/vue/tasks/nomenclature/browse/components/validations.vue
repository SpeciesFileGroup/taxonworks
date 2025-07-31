<template>
  <SoftValidations
    class="margin-medium-bottom full_width"
    :validations="validations"
  />
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { SoftValidation } from '@/routes/endpoints'
import SoftValidations from '@/components/soft_validations/panel'

const props = defineProps({
  globalIds: {
    type: Object,
    required: true
  }
})

const validations = ref({})

onBeforeMount(() => {
  const keys = Object.keys(props.globalIds)

  keys.forEach((key) => {
    const section = props.globalIds[key]
    const promises = section.map((globalId) =>
      SoftValidation.find(globalId).then(({ body }) => body)
    )

    Promise.all(promises).then((list) => {
      const validationList = list.filter((item) => item.soft_validations.length)

      if (validationList.length) {
        validations.value[key] = { list: validationList, title: key }
      }
    })
  })
})
</script>
