/**
 * Mermaid-js loader
 */

const MERMAID = 'mermaid';
const themeMap = Theme.newThemeMap('default', 'dark');
let renderId = 0;

async function renderMermaidNodes(nodes) {
  for (const node of nodes) {
    try {
      const source = node.textContent;
      const { svg, bindFunctions } = await mermaid.render(
        `mermaid-diagram-${renderId++}`,
        source
      );
      node.innerHTML = svg;
      node.setAttribute('data-processed', 'true');
      bindFunctions?.(node);
    } catch (error) {
      node.setAttribute('data-processed', 'error');
      console.error('Unable to render Mermaid diagram.', error);
    }
  }
}

async function refreshTheme(event) {
  if (
    event.source === window &&
    event.data &&
    event.data.id === Theme.eventId
  ) {
    // Re-render the SVG › <https://github.com/mermaid-js/mermaid/issues/311#issuecomment-332557344>
    const mermaidList = document.getElementsByClassName(MERMAID);

    [...mermaidList].forEach((elem) => {
      const svgCode = elem.previousSibling.children.item(0).textContent;
      elem.textContent = svgCode;
      elem.removeAttribute('data-processed');
    });

    const newTheme = themeMap[Theme.resolvedTheme];

    mermaid.initialize({ startOnLoad: false, theme: newTheme });
    await renderMermaidNodes(mermaidList);
  }
}

function setNode(elem) {
  const svgCode = elem.textContent;
  const backup = elem.parentElement;
  backup.classList.add('d-none');
  // Create mermaid node
  const mermaid = document.createElement('pre');
  mermaid.classList.add(MERMAID);
  const text = document.createTextNode(svgCode);
  mermaid.appendChild(text);
  backup.after(mermaid);
}

export async function loadMermaid() {
  if (
    typeof mermaid === 'undefined' ||
    typeof mermaid.initialize !== 'function'
  ) {
    return;
  }

  const initTheme = themeMap[Theme.resolvedTheme];

  const mermaidConf = {
    startOnLoad: false,
    theme: initTheme
  };

  const basicList = document.getElementsByClassName('language-mermaid');
  [...basicList].forEach(setNode);

  mermaid.initialize(mermaidConf);
  await renderMermaidNodes(document.getElementsByClassName(MERMAID));

  if (Theme.isToggleable) {
    window.addEventListener('message', refreshTheme);
  }
}
