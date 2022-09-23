import { SVGDraw } from '@sfgrp/svg-detailer'

export default ({ state }, element) => {
  state.SVGBoard = new SVGDraw(element)
}
