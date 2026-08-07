import { ref, computed, watch } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { Container } from '@/routes/endpoints'

function containerSummary(c) {
  return {
    id: c.id,
    name: c.name || c.type?.split('::').pop() || `Container ${c.id}`,
    type: c.type,
    size_x: c.size_x,
    size_y: c.size_y
  }
}

export function useZoomStack(buildingIdRef) {
  const zoomStack = ref([])
  const children = ref([])
  const loading = ref(false)

  const currentContainer = computed(
    () => zoomStack.value[zoomStack.value.length - 1] || null
  )

  const placedCells = computed(() =>
    children.value
      .filter((c) => c.disposition_x != null && c.disposition_y != null)
      .map((c) => ({
        col: c.disposition_x,
        row: c.disposition_y,
        label: c.name.slice(0, 4),
        name: c.name,
        cssClass: c.has_children
          ? 'grid-cell-placed grid-cell-drillable'
          : 'grid-cell-placed'
      }))
  )

  const unplacedChildren = computed(() =>
    children.value.filter(
      (c) =>
        c.disposition_x == null &&
        c.disposition_y == null &&
        c.disposition_z == null
    )
  )

  async function loadAll(buildingId) {
    loading.value = true
    const { body } = await Container.find(buildingId)
    if (body?.id) {
      zoomStack.value = [containerSummary(body)]
      await loadChildren(buildingId)
    }
    loading.value = false
  }

  async function loadChildren(containerId) {
    const { body } = await AjaxCall(
      'get',
      '/tasks/containers/collection_layout/children.json',
      {
        params: { container_id: containerId }
      }
    )
    children.value = Array.isArray(body) ? body : []
  }

  async function drillInto(child) {
    if (!child?.has_children) return
    const { body } = await Container.find(child.id)
    if (!body?.id) return
    zoomStack.value = [...zoomStack.value, containerSummary(body)]
    await loadChildren(body.id)
  }

  async function zoomTo(index) {
    if (index === zoomStack.value.length - 1) return
    zoomStack.value = zoomStack.value.slice(0, index + 1)
    await loadChildren(zoomStack.value[index].id)
  }

  async function navigateTo(path) {
    if (!path?.length) return
    const target = path[path.length - 1]
    loading.value = true
    const { body } = await Container.find(target.id)
    if (body?.id) {
      const ancestors = path.slice(0, -1).map((p) => ({
        id: p.id,
        name: p.name,
        type: p.type,
        size_x: null,
        size_y: null
      }))
      zoomStack.value = [...ancestors, containerSummary(body)]
      await loadChildren(body.id)
    }
    loading.value = false
  }

  function patchCurrentSize({ size_x, size_y }) {
    const idx = zoomStack.value.length - 1
    if (idx < 0) return
    zoomStack.value = [
      ...zoomStack.value.slice(0, idx),
      { ...zoomStack.value[idx], size_x, size_y }
    ]
  }

  function renameInStack(id, newName) {
    children.value = children.value.map((c) =>
      c.id === id ? { ...c, name: newName } : c
    )
    zoomStack.value = zoomStack.value.map((z) =>
      z.id === id ? { ...z, name: newName } : z
    )
  }

  watch(
    buildingIdRef,
    async (id) => {
      zoomStack.value = []
      children.value = []
      if (id) await loadAll(id)
    },
    { immediate: true }
  )

  return {
    zoomStack,
    children,
    loading,
    currentContainer,
    placedCells,
    unplacedChildren,
    loadChildren,
    drillInto,
    zoomTo,
    navigateTo,
    patchCurrentSize,
    renameInStack
  }
}
