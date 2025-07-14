import PreviousFuture from '../../previous_future/app.vue'
import FullKey from '../../full_key/app.vue'
import useStore from '../../store/leadStore'

const LAYOUTS_ARRAY = ['PreviousFuture', 'FullKey']

const LAYOUTS = Object.fromEntries(LAYOUTS_ARRAY.map(l => [l, l]))

const LAYOUT_COMPONENTS = {
  PreviousFuture: PreviousFuture,
  FullKey: FullKey,
}

function nextLayout() {
  const store = useStore()
  const curIndex = LAYOUTS_ARRAY.indexOf(store.layout)
  const nextIndex = (curIndex + 1) % LAYOUTS_ARRAY.length

  return LAYOUTS[LAYOUTS_ARRAY[nextIndex]]
}

export { LAYOUTS, LAYOUT_COMPONENTS, nextLayout }
