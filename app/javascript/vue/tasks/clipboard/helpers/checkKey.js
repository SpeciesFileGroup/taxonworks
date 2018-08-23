export default function(e) {
  let evtobj = window.event? event : e
  if (evtobj.keyCode == 90 && evtobj.ctrlKey) alert("Ctrl+z");
}