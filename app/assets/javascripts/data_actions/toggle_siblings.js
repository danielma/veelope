function listen(event, selector, callback) {
  document.addEventListener(event, (e) => {
    if (e.target.matches(selector)) {
      callback(e)
    }
  })
}

function siblings(node) {
  const parent = node.parentNode
  const output = []
  let next = parent.firstElementChild

  while (next) {
    if (next !== node) { output.push(next) }
    next = next.nextElementSibling
  }

  return output
}

function rememberKey(node) {
  return `${node.textContent}${node.className}_isVisible`
}

function toggleSiblings(node) {
  const toggledSiblings = siblings(node).map(toggle)

  return toggledSiblings[0]
}

function toggle(node) {
  if (node.style.display === "none") {
    node.style.display = null
    return true
  } else {
    node.style.display = "none"
    return false
  }
}

export function attach() {
  document.addEventListener("turbolinks:load", () => {
    const nodes = document.querySelectorAll("[data-toggle-siblings]")

    nodes.forEach((node) => {
      const key = rememberKey(node)
      const initialVisible = localStorage.getItem(key)

      if (initialVisible === "false") {
        toggleSiblings(node)
      }
    })
  })

  listen("click", "[data-toggle-siblings]", (event) => {
    const visible = !!toggleSiblings(event.target)
    localStorage.setItem(rememberKey(event.target), visible)
  })
}

export default exports
