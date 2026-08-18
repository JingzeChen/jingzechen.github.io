function archiveNameFromHash(hash, names) {
  const match = hash.match(/^#archive-(reading|courses|listening)$/);
  return match && names.includes(match[1]) ? match[1] : names[0];
}

export function initArchiveDirectory() {
  const directory = document.querySelector('[data-archive-directory]');
  if (!directory) {
    return;
  }

  const tabs = [...directory.querySelectorAll('[data-archive-tab]')];
  const panels = [...directory.querySelectorAll('[data-archive-panel]')];
  const names = tabs.map((tab) => tab.dataset.archiveTab);

  const activate = (name, { focus = false, updateHash = false } = {}) => {
    const activeName = names.includes(name) ? name : names[0];

    tabs.forEach((tab) => {
      const selected = tab.dataset.archiveTab === activeName;
      tab.setAttribute('aria-selected', String(selected));
      tab.tabIndex = selected ? 0 : -1;
      if (selected && focus) {
        tab.focus();
      }
    });

    panels.forEach((panel) => {
      panel.hidden = panel.dataset.archivePanel !== activeName;
    });

    if (updateHash) {
      history.replaceState(null, '', `#archive-${activeName}`);
    }
  };

  tabs.forEach((tab, index) => {
    tab.addEventListener('click', () => {
      activate(tab.dataset.archiveTab, { updateHash: true });
    });

    tab.addEventListener('keydown', (event) => {
      let nextIndex;
      if (event.key === 'ArrowRight') {
        nextIndex = (index + 1) % tabs.length;
      } else if (event.key === 'ArrowLeft') {
        nextIndex = (index - 1 + tabs.length) % tabs.length;
      } else if (event.key === 'Home') {
        nextIndex = 0;
      } else if (event.key === 'End') {
        nextIndex = tabs.length - 1;
      } else {
        return;
      }

      event.preventDefault();
      activate(tabs[nextIndex].dataset.archiveTab, {
        focus: true,
        updateHash: true
      });
    });
  });

  window.addEventListener('hashchange', () => {
    activate(archiveNameFromHash(location.hash, names));
  });

  activate(archiveNameFromHash(location.hash, names));
  directory.dataset.archiveReady = 'true';
}
