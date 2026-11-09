import { nextTick, ref, shallowRef } from 'vue'

export function useRadialOpener() {
  const radial = shallowRef(null)
  const radialRef = ref(null)

  async function openRadial({ component, key, props }) {
    radial.value = { component, key, props }
    await nextTick()
    radialRef.value?.openRadialMenu()
  }

  return { radial, radialRef, openRadial }
}
