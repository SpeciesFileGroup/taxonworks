import smartSelectorOrder from './const/order'

export default function(options) {
  return options.sort(function(a, b) {
    return smartSelectorOrder().indexOf(a) - smartSelectorOrder().indexOf(b);
  });
}