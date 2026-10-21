import { itemBaseSize } from '@/components/LightTable'
import { objectToSource } from './source'

const PRECISION = 100

const round = (n) => Math.round(n * PRECISION) / PRECISION

export const itemKey = (id) => `item-${id}`
export const regionKey = (id) => `group-${id}`

const COLOR_PROPERTY = '--region-color'

export function colorFromCssStyle(cssStyle) {
  const match = cssStyle?.match(new RegExp(`${COLOR_PROPERTY}\\s*:\\s*([^;]+)`))

  return match ? match[1].trim() : null
}

export function colorToCssStyle(color) {
  return color ? `${COLOR_PROPERTY}: ${color}` : null
}

export function groupOffset(group) {
  return { x: group?.x || 0, y: group?.y || 0 }
}

export function groupToRegion(group) {
  return {
    id: regionKey(group.id),
    name: group.text || '',
    color: colorFromCssStyle(group.css_style),
    ...groupOffset(group)
  }
}

export function compositionItemToItem(compositionItem, group) {
  const source = objectToSource(
    compositionItem.composition_item_object_type,
    compositionItem.composition_item_object
  )
  const size =
    compositionItem.width && compositionItem.height
      ? { w: compositionItem.width, h: compositionItem.height }
      : itemBaseSize(source)
  const offset = groupOffset(group)

  return {
    ...source,
    id: itemKey(compositionItem.id),
    w: size.w,
    h: size.h,
    x: (compositionItem.x || 0) + offset.x + size.w / 2,
    y: (compositionItem.y || 0) + offset.y + size.h / 2,
    rotation: compositionItem.rotation_z || 0,
    scale: compositionItem.zoom || 1,
    opacity:
      compositionItem.opacity == null ? 1 : compositionItem.opacity / 100,
    z: compositionItem.z || 0,
    label: compositionItem.text || '',
    regionId: group ? regionKey(group.id) : null
  }
}

export function groupAttributes(group) {
  return {
    text: group.text || null,
    x: round(group.x || 0),
    y: round(group.y || 0),
    css_style: colorToCssStyle(colorFromCssStyle(group.css_style))
  }
}

export function regionToGroupAttributes(region) {
  return groupAttributes({
    text: region.name,
    x: region.x,
    y: region.y,
    css_style: colorToCssStyle(region.color)
  })
}

export function itemAttributes(compositionItem) {
  return {
    parent_id: compositionItem.parent_id || null,
    text: compositionItem.text || null,
    x: round(compositionItem.x || 0),
    y: round(compositionItem.y || 0),
    z: compositionItem.z || 0,
    width: compositionItem.width || null,
    height: compositionItem.height || null,
    zoom: round(compositionItem.zoom || 1),
    rotation_z: round(compositionItem.rotation_z || 0),
    opacity: compositionItem.opacity == null ? 100 : compositionItem.opacity
  }
}

export function itemToAttributes(item, region, parentId) {
  const offset = groupOffset(region)
  const width = Math.round(item.w)
  const height = Math.round(item.h)

  return itemAttributes({
    parent_id: parentId,
    text: item.label,
    x: item.x - width / 2 - offset.x,
    y: item.y - height / 2 - offset.y,
    z: item.z,
    width,
    height,
    zoom: item.scale,
    rotation_z: item.rotation,
    opacity: Math.round(item.opacity * 100)
  })
}
